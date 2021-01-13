use anyhow::{Context, Result};
use ds3_cheatsheet_parser::{
    achievements, armor, playthrough, souls, trades, utils::Utils, weapons_and_shields,
};
use std::path::Path;
use tracing::instrument;
use tracing::{trace, Level};
use tracing_subscriber::FmtSubscriber;
#[derive(Debug, Clone, Copy)]
enum Lang {
    English,
    Russian,
}

impl Lang {
    fn code(&self) -> &'static str {
        match self {
            Lang::English => "en",
            Lang::Russian => "ru",
        }
    }
}

fn setup() {
    let subscriber = FmtSubscriber::builder()
        // .pretty()
        .with_max_level(Level::TRACE)
        // .with_env_filter(EnvFilter::from_default_env())
        // .with_max_level(Level::TRACE)
        .finish();
    tracing::subscriber::set_global_default(subscriber).expect("setting default subscriber failed");
}

fn main() -> Result<()> {
    setup();
    let repo_path =
        Path::new(env!("CARGO_MANIFEST_DIR")).join("target/ZKjellberg_dark-souls-3-cheat-sheet");
    let repo = if let Ok(repo) = git2::Repository::open(&repo_path) {
        println!("Repo found at {}", &repo_path.to_string_lossy());
        repo
    } else {
        println!("Cloning repo to {}", repo_path.to_string_lossy());
        git2::Repository::clone(
            "https://github.com/ZKjellberg/dark-souls-3-cheat-sheet.git",
            &repo_path,
        )
        .expect("could clone repository")
    };
    // fast_forward(&repo).expect("git2 error");
    drop(repo);

    // let html_path = repo_path.join("index.html");
    // let html = {
    //     let html = std::fs::read_to_string(&html_path)
    //         .with_context(|| format!("cannot read or open: {}", html_path.display()))?;

    //     select::document::Document::from(html.as_str())
    // };
    // parse_html("achievements", &html, achievements::Achievements)?;
    for lang in &[Lang::Russian] {
        gen_fb_for_json("achievements", achievements::Achievements, lang)?;
        gen_fb_for_json("armor", armor::Armors, lang)?;
        gen_fb_for_json("playthrough", playthrough::Playthroughs, lang)?;
        gen_fb_for_json("souls", souls::Souls, lang)?;
        gen_fb_for_json("trades", trades::Trades, lang)?;
        gen_fb_for_json(
            "weapons_and_shields",
            weapons_and_shields::WSCategories,
            lang,
        )?;
    }

    Ok(())
}
#[instrument]
fn gen_fb_for_json<T: Utils>(basename: &str, _: T, lang: &Lang) -> Result<()> {
    let mut builder = flatbuffers::FlatBufferBuilder::new_with_capacity(512 * 1024); // 512 KiB
    let input_path = format!("../i18n/{}/{}.json", lang.code(), basename);
    let output_path = format!("../i18n/{}/flatbuffers/{}.fb", lang.code(), basename);
    let json = std::fs::read_to_string(input_path.as_str())
        .with_context(|| format!("file not found: {}", input_path.as_str()))?;
    trace!("parsing json from file: {:?}", &input_path);
    let input = T::parse_json(json.as_str())?;
    trace!("generating flatbuffer: {:?}", &output_path);
    let flat = T::gen_fb(input.as_slice(), &mut builder);
    std::fs::write(output_path.as_str(), flat)
        .with_context(|| format!("cannot create file: {}", output_path.as_str()))?;
    Ok(())
}

#[instrument(skip(html))]
fn parse_html<U>(basename: &str, html: &select::document::Document, _: U) -> Result<()>
where
    U: Utils,
    U::Item: serde::Serialize,
{
    trace!("parsing html");
    let data = U::parse_html(&html)?;
    let path = format!("../i18n/en/{}.json", basename);
    let mut out_file = std::fs::File::create(&path)?;
    trace!("writting json to {:?}", &path);
    serde_json::to_writer_pretty(&mut out_file, &data)?;
    Ok(())
}
