use crate::utils::{Markdown, Utils};
use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

#[allow(dead_code, unused_imports)]
#[path = "../target/flatbuffers/trades_generated.rs"]
mod trades_generated;
pub use trades_generated::ds3c as fb;

#[derive(Debug, Serialize, Deserialize)]
pub struct Trade {
    what: Markdown,
    #[serde(rename = "for")]
    for_: Markdown,
}
#[derive(Debug, Clone, Copy)]
pub struct Trades;
impl Utils for Trades {
    type Input = Trade;

    fn gen_fb<'i>(
        input: &'i [Self::Input],
        builder: &'i mut flatbuffers::FlatBufferBuilder,
    ) -> &'i [u8] {
        let mut trades = Vec::with_capacity(input.len());
        for trade in input {
            let for_ = builder.create_string(trade.for_.as_str());
            let what = builder.create_string(trade.what.as_str());
            trades.push(fb::Trade::create(
                builder,
                &fb::TradeArgs {
                    for_: Some(for_),
                    what: Some(what),
                },
            ));
        }
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

    fn parse_json(input: &str) -> Result<Vec<Self::Input>> {
        serde_json::from_str(input).context("trades json parsing failed")
    }
}
// pub fn gen_fb
