use anyhow::{Context, Result};
use select::document::Document;
use select::predicate::{And, Attr, Name, Not};
use serde::{Deserialize, Serialize};
use url::Url;

#[allow(dead_code, unused_imports)]
#[path = "../../target/flatbuffers/playthrough_generated.rs"]
mod playthrough_generated;
pub use playthrough_generated::ds3c::playthrough as fb;

#[derive(Debug, Serialize, Deserialize)]
pub struct Playthrough {
    location: Location,
    tasks: Vec<Task>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Markdown(String);

#[derive(Debug, Serialize, Deserialize)]
pub struct Task {
    data_id: String,
    tags: Vec<String>,
    text: Markdown,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Location {
    name: String,
    link: url::Url,
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
            let name = location.inner_html();
            let link = url::Url::parse(
                location
                    .attr("href")
                    .context("no href attribute in the location element")?,
            )
            .context("bad URL in location's name")?;

            Location { name, link, note }
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
                let mut buf = String::with_capacity(256);
                for child in task.children() {
                    if let Some(text) = child.as_text() {
                        buf.push_str(text);
                    } else if child.is(Name("span")) {
                        buf.push_str(child.inner_html().as_str());
                    } else {
                        let link = child.attr("href").with_context(|| {
                            format!(
                                "playthrough: link in text must contain href, html = {}",
                                child.html()
                            )
                        })?;
                        if link == "#" {
                            buf.push_str(child.text().as_str());
                        } else {
                            let url = Url::parse(link).with_context(|| {
                                println!("{}", task.html());
                                format!("playthrough: link must be valid, link = {}", link)
                            })?;
                            let md_link = format!("[{}]({})", child.text(), url);
                            buf.push_str(&md_link);
                        }
                    }
                }
                tasks.push(Task {
                    data_id: data_id.to_owned(),
                    tags,
                    text: Markdown(buf),
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
    mut builder: &'buf mut flatbuffers::FlatBufferBuilder,
) -> &'buf [u8] {
    // let mut builder = flatbuffers::FlatBufferBuilder::new_with_capacity(1024);
    let mut pts = Vec::with_capacity(items.len());
    for p in items {
        let mut tasks = Vec::with_capacity(p.tasks.len());
        for task in p.tasks.iter() {
            let data_id = builder.create_string(task.data_id.as_str());
            let tags = task.tags.iter().map(|x| x.as_str()).collect::<Vec<_>>();
            let tags = builder.create_vector_of_strings(tags.as_slice());
            let text = builder.create_string(task.text.0.as_str());

            let mut task_buidler = fb::TaskBuilder::new(&mut builder);
            task_buidler.add_data_id(data_id);
            task_buidler.add_tags(tags);
            task_buidler.add_text(text);
            let task = task_buidler.finish();
            tasks.push(task);
        }
        let tasks = builder.create_vector(&tasks);

        let name = builder.create_string(p.location.name.as_str());
        let link = builder.create_string(p.location.link.to_string().as_str());

        let mut loc_builder = fb::LocationBuilder::new(&mut builder);
        loc_builder.add_link(link);
        loc_builder.add_name(name);
        let location = loc_builder.finish();

        let mut pt_builder = fb::PlaythroughBuilder::new(&mut builder);
        pt_builder.add_tasks(tasks);
        pt_builder.add_location(location);
        pts.push(pt_builder.finish());
    }
    let items = builder.create_vector(&pts);
    let mut root_builder = fb::PlaythroughRootBuilder::new(&mut builder);
    root_builder.add_items(items);
    let root = root_builder.finish();
    builder.finish(root, None);
    builder.finished_data()
}
