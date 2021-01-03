mod types;
use once_cell::sync::Lazy;
use scraper::{ElementRef, Html, Selector};
use serde::{Deserialize, Serialize};
use std::fs::read_to_string;
pub use types::*;

pub fn generate() {
    let weap_html = read_to_string("weapons.html").unwrap();
    let shields_html = read_to_string("shields.html").unwrap();

    let weap_doc = Html::parse_fragment(&weap_html);
    let shields_doc = Html::parse_fragment(&shields_html);

    let weap_tree = weap_doc.root_element();
    let shield_tree = shields_doc.root_element();

    let weaps = parse_weapons(weap_tree);
    let shields = parse_shields(shield_tree);

    std::fs::write("weapons.json", serde_json::to_string(&weaps).unwrap()).unwrap();
    std::fs::write("shields.json", serde_json::to_string(&shields).unwrap()).unwrap();
}

fn parse_weapons(tree: ElementRef) -> Vec<WeaponCategory> {
    let sh4 = Selector::parse("h4").unwrap();
    let sul = Selector::parse("ul").unwrap();
    let sinpitem = Selector::parse("span.item_content").unwrap();

    let categories = tree.select(&sh4);
    let names = tree.select(&sul);

    let mut weapons = Vec::new();
    for (catagory, names) in categories.zip(names) {
        let category = catagory.text().collect::<String>();
        let mut item_names = Vec::new();
        for name in names.select(&sinpitem) {
            item_names.push(name.inner_html());
        }
        weapons.push(WeaponCategory{
            category, weapon_names: item_names,
        })
    }

    weapons
}

fn parse_shields(tree: ElementRef) -> Vec<ShieldCategory> {
    let sh4 = Selector::parse("h4").unwrap();
    let sul = Selector::parse("ul").unwrap();
    let sinpitem = Selector::parse("span.item_content").unwrap();

    let categories = tree.select(&sh4);
    let names = tree.select(&sul);

    let mut shields = Vec::new();
    for (catagory, names) in categories.zip(names) {
        let category = catagory.text().collect::<String>();
        let mut item_names = Vec::new();
        for name in names.select(&sinpitem) {
            item_names.push(name.inner_html());
        }
        shields.push(ShieldCategory{category, shield_names: item_names});
    }

    shields
}
