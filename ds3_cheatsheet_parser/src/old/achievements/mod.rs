mod types;
use once_cell::sync::Lazy;
use scraper::{ElementRef, Html, Selector};
use serde::{Deserialize, Serialize};
use std::fs::read_to_string;
use types::*;

pub fn generate() {
    let html = read_to_string("htmls/achievements_except_rings.html").unwrap();
    let document = Html::parse_fragment(&html);
    let snames = Selector::parse("h3").unwrap();
    let slist = Selector::parse("ul").unwrap();
    let names = document.select(&snames);
    let list = document.select(&slist);
    let it = names.zip(list);

    let rings = parse_rings();
    let mut achievements = Vec::new();
    for (name_tree, list_tree) in it {
        let name = parse_name(name_tree);
        let tasks = parse_tasks(list_tree);

        achievements.push(Achievement { name, tasks });
    }
    achievements.push(rings);
    std::fs::write("database/achievements-new.json", serde_json::to_string(&achievements).unwrap()).unwrap();
}

fn parse_name(tree: ElementRef) -> String {
    tree.text()
        .map(|x| {
            x.chars()
                .filter(|c| c.is_ascii_alphabetic() || c == &':' || c == &' ')
                .collect::<String>()
        })
        .collect()
}

static S_SPAN_ITEM_CONTENT: Lazy<Selector> =
    Lazy::new(|| Selector::parse("span.item_content").unwrap());

fn parse_tasks(tree: ElementRef) -> Vec<Task> {
    let mut tasks = Vec::new();
    for text in tree.select(&S_SPAN_ITEM_CONTENT) {
        let html = text.inner_html();

        let mut count_semicolon = 0;
        let mut pos = None;
        if html.starts_with("<strong>")
            || html.starts_with("Covenant")
            || html.starts_with("(No Achievement) Covenan")
            || html.starts_with("<b>")
        {
            pos = Some(html.find(':').unwrap());
        } else {
            for (i, c) in html.chars().enumerate() {
                if c == ':' {
                    count_semicolon += 1;
                }
                if count_semicolon == 2 {
                    pos = Some(i);
                    break;
                }
            }
        }

        let splitted = html.split_at(pos.unwrap());

        tasks.push(Task {
            item_name: splitted.0.to_string(),
            description: splitted.1.to_string(),
            available_from: Journey::NG,
        });
    }
    tasks
}

fn parse_rings() -> Achievement {
    let html = read_to_string("htmls/achievements_only_rings.html").unwrap();
    let document = Html::parse_fragment(&html);
    let snames = Selector::parse("h4").unwrap();
    let slist = Selector::parse("ul").unwrap();
    let names = document.select(&snames);
    let list = document.select(&slist);
    let it = names.zip(list);

    let mut tasks = Vec::new();
    for (name_tree, list_tree) in it {
        let name = name_tree.text().collect::<String>();
        if !name.ends_with("Playthrough)") {
            panic!("something wrong");
        }
        let mut t = parse_tasks(list_tree);
        let pt = match name.as_str() {
            "New Game (First Playthrough)" => Journey::NG,
            "NG+ (Second Playthrough)" => Journey::NGp,
            "NG++ (Third Playthrough)" => Journey::NGpp,
            _ => unreachable!(),
        };
        for el in t.iter_mut(){
            el.available_from = pt;
        }
        tasks.append(&mut t);
    }
    Achievement{
        name: "Master of Rings: Acquire all rings".to_string(),
        tasks,
    }
}
