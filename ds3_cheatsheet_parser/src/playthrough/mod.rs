use crate::utils::Markdown;
use anyhow::{Context, Result};
use select::document::Document;
use select::predicate::{And, Attr, Name, Not};
use serde::{Deserialize, Serialize};

#[allow(dead_code, unused_imports)]
#[path = "../../target/flatbuffers/playthrough_generated.rs"]
mod playthrough_generated;
pub use playthrough_generated::ds3c as fb;

#[derive(Debug, Serialize, Deserialize)]
pub struct Playthrough {
    location: Location,
    tasks: Vec<Task>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Task {
    data_id: String,
    tags: Vec<String>,
    text: Markdown,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Location {
    name: Markdown,
    /// Optional or Require DLC
    note: Option<String>,
}

pub fn parse(html: &Document) -> Result<Vec<Playthrough>> {
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
                let data_id = task.attr("data-id").context("no data-id in task")?;
                let tags = task
                    .attr("class")
                    .context("playthrough: no class in task")?
                    .split_ascii_whitespace()
                    .map(ToOwned::to_owned)
                    .collect::<Vec<_>>();

                tasks.push(Task {
                    data_id: data_id.to_owned(),
                    tags,
                    text: Markdown::parse(&task),
                });
            }
            tasks
        };
        v.push(Playthrough { location, tasks });
    }
    Ok(v)
}

pub fn gen_fb<'a, 'buf>(
    items: &'a [Playthrough],
    builder: &'buf mut flatbuffers::FlatBufferBuilder,
) -> &'buf [u8] {
    let mut pts = Vec::with_capacity(items.len());
    for p in items {
        let mut tasks = Vec::with_capacity(p.tasks.len());
        for task in p.tasks.iter() {
            let data_id = builder.create_string(task.data_id.as_str());
            let tags = task.tags.iter().map(|x| x.as_str()).collect::<Vec<_>>();
            let tags = builder.create_vector_of_strings(tags.as_slice());
            let text = builder.create_string(task.text.as_str());

            let mut task_buidler = fb::TaskBuilder::new(builder);
            task_buidler.add_data_id(data_id);
            task_buidler.add_tags(tags);
            task_buidler.add_text(text);
            let task = task_buidler.finish();
            tasks.push(task);
        }
        let tasks = builder.create_vector(&tasks);

        let name = builder.create_string(p.location.name.as_str());

        let note = if let Some(note) = p.location.note.as_ref() {
            Some(builder.create_string(note.as_str()))
        } else {
            None
        };
        let mut loc_builder = fb::LocationBuilder::new(builder);
        loc_builder.add_name(name);

        if let Some(note) = note {
            loc_builder.add_note(note);
        }
        let location = loc_builder.finish();

        let mut pt_builder = fb::PlaythroughBuilder::new(builder);
        pt_builder.add_tasks(tasks);
        pt_builder.add_location(location);
        pts.push(pt_builder.finish());
    }
    let items = builder.create_vector(&pts);
    let mut root_builder = fb::PlaythroughRootBuilder::new(builder);
    root_builder.add_items(items);
    let root = root_builder.finish();
    builder.finish(root, None);
    builder.finished_data()
}
