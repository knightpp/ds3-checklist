use crate::utils::{Markdown, Utils};
use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

#[allow(dead_code, unused_imports)]
#[path = "../target/flatbuffers/weapons_and_shields_generated.rs"]
mod ws_generated;
pub use ws_generated::ds3c as fb;

#[derive(Debug, Deserialize, Serialize)]
pub struct WSCategory {
    #[serde(rename = "category")]
    name: String,
    #[serde(rename = "item_names")]
    items: Vec<Markdown>,
}
#[derive(Debug, Clone, Copy)]
pub struct WSCategories;

impl Utils for WSCategories {
    type Item = WSCategory;

    fn gen_fb<'i>(
        input: &'i [Self::Item],
        builder: &'i mut flatbuffers::FlatBufferBuilder,
    ) -> &'i [u8] {
        let mut v = Vec::with_capacity(input.len());
        for cat in input {
            let name = builder.create_string(cat.name.as_str());
            let items = builder.create_vector_of_strings(
                &cat.items.iter().map(|x| x.as_str()).collect::<Box<_>>(),
            );
            let cat = fb::Category::create(
                builder,
                &fb::CategoryArgs {
                    items: Some(items),
                    name: Some(name),
                },
            );
            v.push(cat);
        }
        let items = Some(builder.create_vector(&v));
        let root =
            fb::WeaponsAndShieldsRoot::create(builder, &fb::WeaponsAndShieldsRootArgs { items });
        builder.finish(root, None);
        builder.finished_data()
    }

    fn parse_json(input: &str) -> Result<Vec<Self::Item>> {
        serde_json::from_str(input).context("weapons_and_shields json parsing failed")
    }
}
