use crate::utils::Markdown;
use select::predicate::{Attr, Name};
use select::{document::Document, node::Node};
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
    note: Option<String>,
}

fn parse_normal<'a>(node: &Node<'a>, id: &str) -> Achievement {
    let h3 = node.select(Attr("id", id)).next().expect("not found");
    let ul = node
        .select(Attr("id", format!("{}_col", id).as_str()))
        .next()
        .expect("not found");
    let mut tasks = Vec::with_capacity(50);
    for li in ul.select(Name("li")) {
        let id = li.attr("data-id").expect("data-id not found").to_owned();
        let md = Markdown::parse(&li);
        tasks.push(Task {
            id,
            text: md,
            note: None,
        });
    }
    let name = Markdown::parse(&h3);
    let id = h3.attr("id").expect("h3 must have id attr").to_owned();
    Achievement { id, tasks, name }
}

pub fn parse(html: &Document) -> Vec<Achievement> {
    let root = html
        .select(Attr("id", "item_list"))
        .next()
        .expect("html element with id=item_list not found");
    const IDS: [&str; 11] = [
        "Master_of_Expression",
        "Master_of_Sorceries",
        "Master_of_Pyromancies",
        "Master_of_Miracles",
        "DLC_Spells",
        "DLC_Rings",
        "Master_of_Infusion",
        "Ending_Achievements",
        "Boss_Achievements",
        "Misc_Achievements",
        "Covenants_Achievements",
    ];
    let mut vec = Vec::with_capacity(16);
    // special parsing of rings
    {
        let h3 = root.select(Attr("id", "Master_of_Rings")).next().unwrap();
        let div = root
            .select(Attr("id", "Master_of_Rings_col"))
            .next()
            .unwrap();
        let h4s = div.select(Name("h4"));
        let uls = div.select(Name("ul"));
        assert_eq!(
            div.select(Name("h4")).count(),
            div.select(Name("ul")).count()
        );
        let mut tasks = Vec::with_capacity(64);
        for (newgame, ul) in h4s.zip(uls) {
            let note = newgame.text();
            for li in ul.select(Name("li")) {
                let id = li.attr("data-id").expect("data-id not found").to_owned();
                let md = Markdown::parse(&li);
                tasks.push(Task {
                    id,
                    text: md,
                    note: Some(note.clone()),
                });
            }
        }
        let id = h3.attr("id").expect("h3 must have id attr").to_owned();
        let name = Markdown::parse(&h3);
        vec.push(Achievement { id, name, tasks });
    }
    for id in IDS.iter() {
        vec.push(parse_normal(&root, id));
    }
    vec.push(parse_normal(&root, "Master_of_Expression"));
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
            let note = task
                .note
                .as_ref()
                .map(|note| builder.create_string(note.as_str()));
            let task = fb::Task::create(
                builder,
                &fb::TaskArgs {
                    id: Some(task_id),
                    text: Some(task_text),
                    note,
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
