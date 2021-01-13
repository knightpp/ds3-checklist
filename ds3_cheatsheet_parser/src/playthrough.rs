use crate::utils::{Markdown, Utils};
use anyhow::{Context, Result};
use regex::Regex;
use select::document::Document;
use select::predicate::{And, Attr, Name, Not};
use serde::{Deserialize, Serialize};

#[allow(dead_code, unused_imports)]
#[path = "../target/flatbuffers/playthrough_generated.rs"]
mod playthrough_generated;
pub use playthrough_generated::ds3c as fb;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Playthrough {
    location: Location,
    tasks: Vec<Task>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Task {
    id: u32,
    tags: Vec<String>,
    text: Markdown,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Location {
    name: Markdown,
    /// Optional or Require DLC
    note: Option<String>,
}

#[derive(Debug, Clone, Copy)]
pub struct Playthroughs;

impl<'p> Utils for Playthroughs {
    type Item = Playthrough;

    fn gen_fb<'i>(
        items: &'i [Self::Item],
        builder: &'i mut flatbuffers::FlatBufferBuilder,
    ) -> &'i [u8] {
        let mut pts = Vec::with_capacity(items.len());
        let regex = Regex::new(r"^\[(.+)\](.+)$").unwrap();
        for p in items {
            let tasks = {
                let tasks = p
                    .tasks
                    .iter()
                    .map(|task| {
                        let tags = builder.create_vector_of_strings(
                            &task.tags.iter().map(|x| x.as_str()).collect::<Vec<_>>(),
                        );
                        let text = builder.create_string(task.text.as_str());
                        fb::Task::create(
                            builder,
                            &fb::TaskArgs {
                                id: task.id,
                                tags: Some(tags),
                                text: Some(text),
                            },
                        )
                    })
                    .collect::<Vec<_>>();
                builder.create_vector(&tasks)
            };

            let loc = {
                let caps = regex
                    .captures(p.location.name.as_str())
                    .with_context(|| {
                        format!("regex not found matching strings: {:?}", p.location.name)
                    })
                    .unwrap();

                let name = builder.create_string(caps.get(1).unwrap().as_str());
                let note = p
                    .location
                    .note
                    .as_ref()
                    .map(|note| builder.create_string(note.as_str()));
                fb::Location::create(
                    builder,
                    &fb::LocationArgs {
                        name: Some(name),
                        note: note,
                    },
                )
            };
            let pt = fb::Playthrough::create(
                builder,
                &fb::PlaythroughArgs {
                    location: Some(loc),
                    tasks: Some(tasks),
                },
            );

            pts.push(pt);
        }
        let items = builder.create_vector(&pts);
        let mut root_builder = fb::PlaythroughRootBuilder::new(builder);
        root_builder.add_items(items);
        let root = root_builder.finish();
        builder.finish(root, None);
        builder.finished_data()
    }
    #[allow(unused_variables)]
    fn parse_json(input: &str) -> Result<Vec<Self::Item>> {
        serde_json::from_str(input).context("playthrough json parsing failed")
    }

    fn parse_html(html: &Document) -> Result<Vec<Self::Item>> {
        let list = html
            .select(Attr("id", "playthrough_list"))
            .next()
            .context("html element with id=playthrough_list not found")?;

        let h3 = Name("h3");
        let ul = Name("ul");
        let li = Name("li");

        let location_names = list.select(h3);
        let task_lists = list.select(ul);

        let mut v = Vec::<Playthrough>::with_capacity(20);
        let mut task_id = 0;
        for (location, task_list) in location_names.zip(task_lists) {
            let note = {
                let note = location
                    .children()
                    .map(|x| x.as_text())
                    .find(|x| x.is_some())
                    .unwrap()
                    .unwrap()
                    .trim();
                if note.is_empty() {
                    None
                } else {
                    Some(note.to_owned())
                }
            };
            let location = {
                let location = location
                    .children()
                    .find(|x| x.is(And(Name("a"), Not(Attr("class", ())))))
                    .context("playthrough: could not find location name/link")?;
                let name = location.text();
                let link = url::Url::parse(
                    location
                        .attr("href")
                        .context("no href attribute in the location element")?,
                )
                .context("bad URL in location's name")?;

                Location {
                    name: Markdown::new_link(&name, link),
                    note,
                }
            };
            let tasks = {
                let mut tasks = Vec::<Task>::with_capacity(32);
                for task in task_list.select(li) {
                    // let data_id = task.attr("data-id").context("no data-id in task")?;
                    let tags = task
                        .attr("class")
                        .context("playthrough: no class in task")?
                        .split_ascii_whitespace()
                        .map(ToOwned::to_owned)
                        .collect::<Vec<_>>();

                    tasks.push(Task {
                        id: task_id,
                        tags,
                        text: Markdown::parse(&task),
                    });
                    task_id += 1;
                }
                tasks
            };
            v.push(Playthrough { location, tasks });
        }
        Ok(v)
    }
}
