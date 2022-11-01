use crate::utils::{Markdown, Utils};
use anyhow::Context;
use serde::{Deserialize, Serialize};

#[allow(dead_code, unused_imports)]
#[path = "../target/flatbuffers/achievements_generated.rs"]
mod achievements_generated;
pub use achievements_generated::ds3_c as fb;

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Achievement {
    name: Markdown,
    tasks: Vec<Task>,
}

impl Achievement {
    pub fn name(&self) -> &Markdown {
        &self.name
    }
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Task {
    id: u32,
    text: Markdown,
    play: u8,
}

#[derive(Debug, Clone, Copy)]
pub struct Achievements;

impl Utils for Achievements {
    type Item = Achievement;

    fn gen_fb<'i>(
        items: &'i [Self::Item],
        builder: &'i mut flatbuffers::FlatBufferBuilder,
    ) -> &'i [u8] {
        let mut achs = Vec::with_capacity(items.len());
        for ach in items {
            let tasks = {
                let tasks = ach
                    .tasks
                    .iter()
                    .map(|task| {
                        let raw = task.text.as_str();
                        let (name, description) =
                            raw.split_at(raw.rfind(": ").expect("semicolon not found"));

                        let description = description
                            .strip_prefix(": ")
                            .with_context(|| format!("cannot strip prefix for {:?}", description))
                            .unwrap();
                        let args = fb::TaskArgs {
                            id: task.id,
                            name: Some(builder.create_string(name)),
                            description: Some(builder.create_string(description)),
                            play: task.play,
                        };
                        fb::Task::create(builder, &args)
                    })
                    .collect::<Vec<_>>();
                builder.create_vector(&tasks)
            };

            let ach = {
                let raw = ach.name.as_str();
                let (name, description) = if let Some(x) = raw.find(": ") {
                    let splitted = raw.split_at(x);
                    (splitted.0, splitted.1.strip_prefix(": ").unwrap())
                } else {
                    (raw, "")
                };

                let args = fb::AchievementArgs {
                    name: Some(builder.create_string(name)),
                    description: Some(builder.create_string(description)),
                    tasks: Some(tasks),
                };
                fb::Achievement::create(builder, &args)
            };
            achs.push(ach);
        }

        let achs = builder.create_vector(&achs);

        let root =
            fb::AchievementsRoot::create(builder, &fb::AchievementsRootArgs { items: Some(achs) });
        builder.finish(root, None);
        builder.finished_data()
    }

    fn parse_json(input: &str) -> anyhow::Result<Vec<Self::Item>> {
        serde_json::from_str(input).context("achievements json parsing failed")
    }
    // lost ability to parse HTML :(
    // fn parse_html(html: &Document) -> anyhow::Result<Vec<Self::Item>> {
    //     let root = html
    //         .select(Attr("id", "item_list"))
    //         .next()
    //         .expect("html element with id=item_list not found");
    //     const IDS: [&str; 11] = [
    //         "Master_of_Expression",
    //         "Master_of_Sorceries",
    //         "Master_of_Pyromancies",
    //         "Master_of_Miracles",
    //         "Master_of_Infusion",
    //         "Ending_Achievements",
    //         "Boss_Achievements",
    //         "Misc_Achievements",
    //         "Covenants_Achievements",
    //         "DLC_Spells",
    //         "DLC_Rings",
    //     ];
    //     let mut task_id = 0;
    //     let mut vec = Vec::with_capacity(16);
    //     // special parsing of rings
    //     {
    //         let h3 = root.select(Attr("id", "Master_of_Rings")).next().unwrap();
    //         let div = root
    //             .select(Attr("id", "Master_of_Rings_col"))
    //             .next()
    //             .unwrap();
    //         let h4s = div.select(Name("h4"));
    //         let uls = div.select(Name("ul"));
    //         assert_eq!(
    //             div.select(Name("h4")).count(),
    //             div.select(Name("ul")).count()
    //         );
    //         let mut tasks = Vec::with_capacity(64);
    //         for (newgame, ul) in h4s.zip(uls) {
    //             let note = newgame.text();
    //             for li in ul.select(Name("li")) {
    //                 let md = Markdown::parse(&li);
    //                 tasks.push(Task {
    //                     id: task_id,
    //                     text: md,
    //                     note: Some(note.clone()),
    //                 });
    //             }
    //         }
    //         let name = Markdown::parse(&h3);
    //         vec.push(Achievement { name, tasks });
    //     }

    //     for id in IDS.iter() {
    //         vec.push(parse_normal(&root, id, &mut task_id));
    //     }
    //     let rings = vec.remove(0);
    //     vec.insert(9, rings);
    //     Ok(vec)
    // }
}

// fn parse_normal<'a>(node: &Node<'a>, id: &str, task_id: &mut u32) -> Achievement {
//     let h3 = node.select(Attr("id", id)).next().expect("not found");
//     let ul = node
//         .select(Attr("id", format!("{}_col", id).as_str()))
//         .next()
//         .expect("not found");
//     let mut tasks = Vec::with_capacity(50);
//     for li in ul.select(Name("li")) {
//         let md = Markdown::parse(&li);
//         tasks.push(Task {
//             id: *task_id,
//             text: md,
//             note: None,
//         });
//     }
//     let name = Markdown::parse(&h3);
//     Achievement { tasks, name }
// }
