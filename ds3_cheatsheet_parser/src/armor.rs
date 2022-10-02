use crate::utils::{Markdown, Utils};
use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
pub struct ArmorCategory {
    category: String,
    #[serde(rename = "gear_names")]
    gears: Vec<Gear>,
}
#[derive(Debug, Deserialize, Serialize)]
pub struct Gear {
    id: u32,
    name: Markdown,
}

#[allow(dead_code, unused_imports)]
#[path = "../target/flatbuffers/armor_generated.rs"]
mod armor_generated;
pub use armor_generated::ds3_c as fb;

#[derive(Debug, Clone, Copy)]
pub struct Armors;

impl Utils for Armors {
    type Item = ArmorCategory;

    fn gen_fb<'i>(
        input: &'i [Self::Item],
        builder: &'i mut flatbuffers::FlatBufferBuilder,
    ) -> &'i [u8] {
        let mut v = Vec::with_capacity(input.len());
        for armor in input {
            let cat = builder.create_string(armor.category.as_str());
            let gears = armor
                .gears
                .iter()
                .map(|g| {
                    let name = builder.create_string(g.name.as_str());
                    fb::Gear::create(
                        builder,
                        &fb::GearArgs {
                            id: g.id,
                            name: Some(name),
                        },
                    )
                })
                .collect::<Vec<_>>();
            let gears = builder.create_vector(&gears);
            v.push(fb::ArmorCategory::create(
                builder,
                &fb::ArmorCategoryArgs {
                    gears: Some(gears),
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
