use anyhow::{Context, Result};
use ds3_cheatsheet_parser::{achievements, playthrough};
use git2::Repository;
use select::document::Document;
use std::{fs::read_to_string, path::Path};
use tracing::{info, info_span, Level};
use tracing_subscriber::FmtSubscriber;

#[allow(dead_code)]
fn fast_forward(repo: &Repository) -> Result<(), git2::Error> {
    repo.find_remote("origin")?.fetch(&["master"], None, None)?;

    let fetch_head = repo.find_reference("FETCH_HEAD")?;
    let fetch_commit = repo.reference_to_annotated_commit(&fetch_head)?;
    let analysis = repo.merge_analysis(&[&fetch_commit])?;
    if analysis.0.is_up_to_date() {
        Ok(())
    } else if analysis.0.is_fast_forward() {
        let refname = format!("refs/heads/{}", "master");
        let mut reference = repo.find_reference(&refname)?;
        reference.set_target(fetch_commit.id(), "Fast-Forward")?;
        repo.set_head(&refname)?;
        repo.checkout_head(Some(git2::build::CheckoutBuilder::default().force()))
    } else {
        panic!("only fast-forward allowed");
    }
}

fn setup() {
    let subscriber = FmtSubscriber::builder()
        // .pretty()
        .with_max_level(Level::INFO)
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

    let html_path = repo_path.join("index.html");
    let html = {
        let html = read_to_string(&html_path)
            .with_context(|| format!("cannot read or open: {}", html_path.display()))?;

        Document::from(html.as_str())
    };

    gen_playthrough(&html)?;
    gen_achievements(&html)?;

    Ok(())
}

fn gen_playthrough(html: &Document) -> Result<()> {
    let span = info_span!("Playthrough");
    span.in_scope::<_, Result<()>>(|| {
        info!("parsing html");
        let pt = playthrough::parse(&html)?;
        let mut f = std::fs::File::create("../i18n/en/playthrough.json")?;
        info!("writing json");
        serde_json::to_writer_pretty(&mut f, &pt)?;
        let mut buf = flatbuffers::FlatBufferBuilder::new_with_capacity(512 * 1024); // 512 KiB
        info!("generating flatbuffers");
        let data = playthrough::gen_fb(&pt, &mut buf);
        info!("writing flatbuffers");
        std::fs::write("../i18n/en/flatbuffers/playthrough.fb", data)?;
        Ok(())
    })?;
    Ok(())
}

fn gen_achievements(html: &Document) -> Result<()> {
    const NAME: &str = "achievements";
    let span = info_span!(NAME);
    span.in_scope::<_, Result<()>>(|| {
        info!("parsing html");
        let achs = achievements::parse(&html);
        let mut f = std::fs::File::create(format!("../i18n/en/{}.json", NAME))?;
        info!("writing json");
        serde_json::to_writer_pretty(&mut f, &achs)?;
        let mut buf = flatbuffers::FlatBufferBuilder::new_with_capacity(512 * 1024); // 512 KiB
        info!("generating flatbuffers");
        let data = achievements::gen_fb(&achs, &mut buf);
        info!("writing flatbuffers");
        std::fs::write(format!("../i18n/en/flatbuffers/{}.fb", NAME), data)?;
        Ok(())
    })?;
    Ok(())
}
