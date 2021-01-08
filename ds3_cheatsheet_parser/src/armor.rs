use crate::utils::{Markdown, Utils};
use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
pub struct Armor {
    category: String,
    gear_names: Vec<Markdown>,
}

#[allow(dead_code, unused_imports)]
#[path = "../target/flatbuffers/armor_generated.rs"]
mod armor_generated;
pub use armor_generated::ds3c as fb;

#[derive(Debug, Clone, Copy)]
pub struct Armors;

impl Utils for Armors {
    type Item = Armor;

    fn gen_fb<'i>(
        input: &'i [Self::Item],
        builder: &'i mut flatbuffers::FlatBufferBuilder,
    ) -> &'i [u8] {
        let mut v = Vec::with_capacity(input.len());
        for armor in input {
            let cat = builder.create_string(armor.category.as_str());
            let gear_names = builder.create_vector_of_strings(
                &armor
                    .gear_names
                    .iter()
                    .map(|a| a.as_str())
                    .collect::<Box<_>>(),
            );
            v.push(fb::ArmorCategory::create(
                builder,
                &fb::ArmorCategoryArgs {
                    gear_names: Some(gear_names),
                    category: Some(cat),
                },
            ));
        }
        let items = Some(builder.create_vector(&v));
        let root = fb::ArmorRoot::create(builder, &fb::ArmorRootArgs { items });
        builder.finish(root, None);
        builder.finished_data()
    }

    fn parse_json(input: &str) -> Result<Vec<Self::Item>> {
        serde_json::from_str(input).context("armor json parsing failed")
    }
}
