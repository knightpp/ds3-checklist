use crate::utils::Markdown;
use select::document::Document;
use select::predicate::{Attr, Name};
use serde::{Deserialize, Serialize};

#[allow(dead_code, unused_imports)]
#[path = "../../target/flatbuffers/achievements_generated.rs"]
mod achievements_generated;
pub use achievements_generated::ds3c as fb;

#[derive(Debug, Deserialize, Serialize)]
pub struct Achievement {
    id: String,
    name: Markdown,
    tasks: Vec<Task>,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Task {
    id: String,
    text: Markdown,
}

pub fn parse(html: &Document) -> Vec<Achievement> {
    let root = html
        .select(Attr("id", "item_list"))
        .next()
        .expect("html element with id=item_list not found");
    let titles = root.select(Name("h3"));
    let lists = root.select(Name("ul"));
    let mut vec = Vec::with_capacity(16);
    for (title_node, list_node) in titles.zip(lists) {
        let mut tasks = Vec::with_capacity(50);
        for li in list_node.select(Name("li")) {
            let id = li.attr("data-id").expect("data-id not found").to_owned();
            let md = Markdown::parse(&li);
            tasks.push(Task { id, text: md });
        }
        let name = Markdown::parse(&title_node);
        let id = title_node
            .attr("id")
            .expect("h3 must have id attr")
            .to_owned();
        vec.push(Achievement { id, name, tasks });
    }
    vec
}

pub fn gen_fb<'a, 'buf>(
    items: &'a [Achievement],
    builder: &'buf mut flatbuffers::FlatBufferBuilder,
) -> &'buf [u8] {
    let mut achs = Vec::with_capacity(items.len());
    for ach in items {
        let id = builder.create_string(&ach.id);
        let name = builder.create_string(ach.name.as_str());
        let mut tasks = Vec::with_capacity(ach.tasks.len());
        for task in ach.tasks.iter() {
            let task_id = builder.create_string(task.id.as_str());
            let task_text = builder.create_string(task.text.as_str());
            let task = fb::Task::create(
                builder,
                &fb::TaskArgs {
                    id: Some(task_id),
                    text: Some(task_text),
                },
            );
            tasks.push(task);
        }
        let tasks = builder.create_vector(&tasks);
        let ach = fb::Achievement::create(
            builder,
            &fb::AchievementArgs {
                id: Some(id),
                name: Some(name),
                tasks: Some(tasks),
            },
        );
        achs.push(ach);
    }

    let achs = builder.create_vector(&achs);

    let root =
        fb::AchievementsRoot::create(builder, &fb::AchievementsRootArgs { items: Some(achs) });
    builder.finish(root, None);
    builder.finished_data()
}
