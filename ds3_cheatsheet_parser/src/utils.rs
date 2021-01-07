use anyhow::Result;
use select::document::Document;
use serde::{Deserialize, Serialize};
use tracing::warn;

#[derive(Debug, Serialize, Deserialize)]
pub struct Markdown(String);

impl Markdown {
    // pub(crate) fn new(string: String) -> Self {
    //     Markdown(string)
    // }
    pub(crate) fn new_link(text: &str, url: url::Url) -> Self {
        Markdown(format!("[{}]({})", text, url))
    }
    pub fn as_str(&self) -> &str {
        self.0.as_str()
    }

    pub(crate) fn parse(node: &select::node::Node) -> Markdown {
        let mut buf = String::with_capacity(1 * 1024);

        fn recursive(node: &select::node::Node, buf: &mut String) {
            for child in node.children() {
                if let Some("a") = child.name() {
                    let href = child.attr("href").expect("all a must have href");
                    if !href.starts_with("http") {
                        warn!("bad link = {}", href);
                        recursive(&child, buf);
                        continue;
                    }
                    url::Url::parse(href).expect("not a valid link");
                    let text_inside_a = child.first_child().expect("a must contain text");
                    let md_link = format!(
                        "[{}]({})",
                        text_inside_a.as_text().expect("expected text"),
                        href
                    );
                    buf.push_str(&md_link);
                } else if let Some(text) = child.as_text() {
                    buf.push_str(text);
                // }
                //  else if let Some("span") = child.name() {
                //     continue;
                } else if let Some("strong") = child.name() {
                    buf.push_str("**");
                    buf.push_str(&child.text());
                    buf.push_str("**");
                } else {
                    recursive(&child, buf);
                }
            }
        }
        recursive(node, &mut buf);
        Markdown(buf.trim().to_owned())
    }
}

pub trait Utils {
    type Input;
    fn gen_fb<'i>(
        input: &'i [Self::Input],
        builder: &'i mut flatbuffers::FlatBufferBuilder,
    ) -> &'i [u8];

    fn parse_json(input: &str) -> Result<Vec<Self::Input>>;

    #[allow(unused_variables)]
    fn parse_html(html: &Document) -> Result<Vec<Self::Input>> {
        todo!()
    }
}
