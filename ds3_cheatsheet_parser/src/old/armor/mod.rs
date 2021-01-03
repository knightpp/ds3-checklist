mod types;
use scraper::{ElementRef, Html, Selector};
use std::fs::read_to_string;
pub use types::*;

pub fn generate() {
    let armor_html = read_to_string("armor_fragment.html").unwrap();
    let armor_doc = Html::parse_fragment(&armor_html);
    let sh3 = Selector::parse("h3").unwrap();
    let sul = Selector::parse("ul").unwrap();
    let ssic = Selector::parse("span.item_content").unwrap();
    let sa = Selector::parse("a").unwrap();

    let cat = armor_doc.select(&sh3);
    let list = armor_doc.select(&sul);

    let mut gears = Vec::new();
    for (cat, list) in cat.zip(list) {
        
        //let category = cat.text().collect::<String>();
        let category = cat.select(&sa).nth(1).unwrap().text().collect::<String>();
        let gear_names = list.select(&ssic).map(|er| er.inner_html()).collect();

        gears.push(ArmorCategory {
            category,
            gear_names,
        });
    }

    std::fs::write("armor.json", serde_json::to_string(&gears).unwrap()).unwrap();
}
