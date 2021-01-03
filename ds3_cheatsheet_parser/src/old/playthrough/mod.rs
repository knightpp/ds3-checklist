use once_cell::sync::Lazy;
use scraper::{Html, Selector};
use serde::{Deserialize, Serialize};
use std::fs::read_to_string;
mod playthrough_types;
pub use playthrough_types::*;

#[derive(Debug, Serialize, Deserialize)]
struct Location {
    name: String,
    from: ContentFrom,
    actions: Vec<Action>,
}
#[derive(Debug, Serialize, Deserialize)]
struct Action {
    raw_str: String,
    /// Types used for filtering
    types: Vec<Type>,
    journey: Journey,
}

pub fn generate() {
    let html = read_to_string("fragment.html").unwrap();
    let document = Html::parse_fragment(&html);
    let snames = Selector::parse("h3").unwrap();
    let slist = Selector::parse("ul").unwrap();

    let names = document.select(&snames);
    let list = document.select(&slist);
    let it = names.zip(list);
    let mut parsed: Vec<Location> = Vec::new();
    for (name_tree, list_tree) in it {
        let (name, from) = parse_name_from_tree(name_tree);
        let actions = parse_list_from_tree(list_tree);
        parsed.push(Location {
            actions,
            from,
            name,
        });
        //println!("{}", name);
    }
    for i in parsed.iter() {
        print!("{}, {:?}", i.name, i.from);
        for a in i.actions.iter() {
            println!("{:#?}, {:#?}", a.journey, a.types);
        }
    }
    std::fs::write("test.json", serde_json::to_string(&parsed).unwrap()).unwrap();
}

static SELECTOR_LI: Lazy<Selector> = Lazy::new(|| Selector::parse("li").unwrap());
fn parse_list_from_tree(tree: scraper::ElementRef) -> Vec<Action> {
    let mut actions: Vec<Action> = Vec::with_capacity(30);
    let li_list = tree.select(&SELECTOR_LI);

    for li_el in li_list {
        let raw_str = li_el.inner_html();
        let mut types = Vec::new();
        let mut journey = None;
        for class in li_el.value().classes() {
            match class {
                "h_ng+" => journey = Some(Journey::NG),
                "s_ng+" => journey = Some(Journey::NGp),
                "s_ng++" => journey = Some(Journey::NGpp),
                "f_estus" => types.push(Type::Upgrades(Upgrades::EstusShards)),
                "f_misc" => types.push(Type::Others(Others::MiscItems)),
                "f_tit" => types.push(Type::Materials(Materials::Titanite)),
                "f_ring" => types.push(Type::Achievements(Achievements::Rings)),
                "f_gest" => types.push(Type::Achievements(Achievements::Gestures)),
                "f_boss" => types.push(Type::Quests(Quests::Bosses)),
                "f_none" => types.push(Type::None),
                "f_weap" => types.push(Type::Gear(Gear::Weapons)),
                "f_arm" => types.push(Type::Gear(Gear::Armor)),
                "f_npc" => types.push(Type::Quests(Quests::NPCs)),
                "f_gem" => types.push(Type::Materials(Materials::Gems)),
                "f_cov" => types.push(Type::Others(Others::Covenants)),
                "f_tome" => types.push(Type::Upgrades(Upgrades::ScrollsOrTomes)),
                "f_ash" => types.push(Type::Upgrades(Upgrades::Ashes)),
                "f_bone" => types.push(Type::Upgrades(Upgrades::UndeadBoneShards)),
                "f_coal" => types.push(Type::Upgrades(Upgrades::Coals)),
                "f_mirac" => types.push(Type::Achievements(Achievements::Miracles)),
                "f_pyro" => types.push(Type::Achievements(Achievements::Pyromancies)),
                "f_sorc" => types.push(Type::Achievements(Achievements::Sorceries)),

                e @ _ => {
                    eprintln!("{}", e);
                    todo!()
                }
            }
        }
        if let None = journey {
            journey = Some(Journey::NG);
        }
        actions.push(Action {
            raw_str,
            journey: journey.unwrap(),
            types,
        });
    }
    actions
}

fn parse_name_from_tree(tree: scraper::ElementRef) -> (String, ContentFrom) {
    let v = tree.text().collect::<Vec<_>>();
    let filtered = v
        .clone()
        .into_iter()
        .map(|x| x.trim())
        .filter(|x| x.len() > 1)
        .map(|x| {
            x.chars()
                .filter(|x| x.is_ascii_alphanumeric() || ['(', ')', ' '].contains(x))
                .collect::<String>()
        })
        .collect::<Vec<_>>();
    let cf = if filtered.len() == 2 {
        let comefrom = &filtered[1];
        if comefrom.starts_with("(Optional)") {
            ContentFrom::BaseGameOptional
        } else if comefrom.starts_with("(The Ringed") {
            ContentFrom::Dlc(Dlc::TheRingedCity)
        } else if comefrom.starts_with("(Ashes of") {
            ContentFrom::Dlc(Dlc::AshesOfAriandel)
        } else {
            unreachable!()
        }
    } else {
        ContentFrom::BaseGame
    };
    (filtered.join(" ").to_string(), cf)
}
