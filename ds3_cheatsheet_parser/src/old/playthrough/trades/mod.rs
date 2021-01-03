use scraper::{ElementRef, Html, Selector};
use std::fs::read_to_string;

pub fn generate() {
    let html = read_to_string("htmls/trades_fragment.html").unwrap();
    let doc = Html::parse_fragment(&html);
    let selector = Selector::parse("span.item_content").unwrap();

    let mut trades = Vec::new();
    for trade in doc.select(&selector) {
        trades.push(trade.inner_html());
    }

    std::fs::write(
        "database/trades.json",
        serde_json::to_string_pretty(&trades).unwrap(),
    )
    .unwrap();
}
