use crate::utils::{Markdown, Utils};
use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
pub struct Armor {
    category: String,
    gear_names: Vec<Markdown>,
}

#[derive(Debug, Clone, Copy)]
pub struct Armors;

impl Utils for Armors {
    type Input = Armor;

    fn gen_fb<'i>(
        input: &'i [Self::Input],
        builder: &'i mut flatbuffers::FlatBufferBuilder,
    ) -> &'i [u8] {
        todo!()
    }

    fn parse_json(input: &str) -> Result<Vec<Self::Input>> {
        serde_json::from_str(input).context("armor json parsing failed")
    }
}
