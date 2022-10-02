use crate::utils::Utils;
use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

#[allow(dead_code, unused_imports)]
#[path = "../target/flatbuffers/souls_generated.rs"]
mod soul_prices_generated;
pub use soul_prices_generated::ds3_c as fb;

#[derive(Debug, Serialize, Deserialize)]
pub struct Soul {
    name: String,
    price: u16,
}
#[derive(Debug, Clone, Copy)]
pub struct Souls;

impl Utils for Souls {
    type Item = Soul;

    fn gen_fb<'i>(
        input: &'i [Self::Item],
        builder: &'i mut flatbuffers::FlatBufferBuilder,
    ) -> &'i [u8] {
        let mut v = Vec::with_capacity(input.len());
        for soul in input {
            let name = builder.create_string(soul.name.as_str());
            let soul = fb::Soul::create(
                builder,
                &fb::SoulArgs {
                    name: Some(name),
                    price: soul.price,
                },
            );
            v.push(soul);
        }
        let items = Some(builder.create_vector(&v));
        let root = fb::SoulsRoot::create(builder, &fb::SoulsRootArgs { items });
        builder.finish(root, None);
        builder.finished_data()
    }

    fn parse_json(input: &str) -> Result<Vec<Self::Item>> {
        serde_json::from_str(input).context("souls json parsing failed")
    }
}
