use crate::utils::{Markdown, Utils};
use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

#[allow(dead_code, unused_imports)]
#[path = "../target/flatbuffers/weapons_and_shields_generated.rs"]
mod ws_generated;
pub use ws_generated::ds3_c as fb;

#[derive(Debug, Deserialize, Serialize)]
pub struct WSCategory {
    #[serde(rename = "category")]
    name: String,
    #[serde(rename = "item_names")]
    items: Vec<Item>,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Item {
    id: u32,
    name: Markdown,
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
            let cat_name = builder.create_string(cat.name.as_str());
            let items = cat
                .items
                .iter()
                .map(|item| {
                    let item_name = builder.create_string(item.name.as_str());
                    fb::Item::create(
                        builder,
                        &fb::ItemArgs {
                            id: item.id,
                            name: Some(item_name),
                        },
                    )
                })
                .collect::<Vec<_>>();
            let items = builder.create_vector(&items);
            let cat = fb::WSCategory::create(
                builder,
                &fb::WSCategoryArgs {
                    name: Some(cat_name),
                    items: Some(items),
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
