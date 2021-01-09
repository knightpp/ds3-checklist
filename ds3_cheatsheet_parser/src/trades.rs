use crate::utils::{Markdown, Utils};
use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

#[allow(dead_code, unused_imports)]
#[path = "../target/flatbuffers/trades_generated.rs"]
mod trades_generated;
pub use trades_generated::ds3c as fb;

#[derive(Debug, Serialize, Deserialize)]
pub struct Trade {
    id: u32,
    what: Markdown,
    for_: Markdown,
}

#[derive(Debug, Clone, Copy)]
pub struct Trades;
impl Utils for Trades {
    type Item = Trade;

    fn gen_fb<'i>(
        input: &'i [Self::Item],
        builder: &'i mut flatbuffers::FlatBufferBuilder,
    ) -> &'i [u8] {
        let trades = input
            .iter()
            .map(|t| {
                let what = builder.create_string(t.what.as_str());
                let for_ = builder.create_string(t.for_.as_str());
                fb::Trade::create(
                    builder,
                    &fb::TradeArgs {
                        id: t.id,
                        what: Some(what),
                        for_: Some(for_),
                    },
                )
            })
            .collect::<Vec<_>>();
        let trades = builder.create_vector(&trades);
        let root = fb::TradesRoot::create(
            builder,
            &fb::TradesRootArgs {
                items: Some(trades),
            },
        );
        builder.finish(root, None);
        builder.finished_data()
    }

    fn parse_json(input: &str) -> Result<Vec<Self::Item>> {
        serde_json::from_str(input).context("trades json parsing failed")
    }
}
// pub fn gen_fb
