use anyhow::{Context, Result};
use ds3_cheatsheet_parser::playthrough;
use git2::Repository;
use select::document::Document;
use std::{
    fs::read_to_string,
    path::{Path, PathBuf},
};

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

fn main() -> Result<()> {
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
    fast_forward(&repo).expect("git2 error");
    drop(repo);

    let html_path = repo_path.join("index.html");
    let html = {
        let html = read_to_string(&html_path)
            .with_context(|| format!("cannot read or open: {}", html_path.display()))?;

        Document::from(html.as_str())
    };

    let pt = playthrough::parse(&html)?;
    // let mut f = std::fs::File::create("../i18n/en/playthrough.json")?;
    // serde_json::to_writer_pretty(&mut f, &pt)?;
    let mut buf = flatbuffers::FlatBufferBuilder::new_with_capacity(512 * 1024);
    let data = playthrough::gen_fb(&pt, &mut buf);
    // std::fs::write("../i18n/en/flatbuffers/playthrough.bfb", data)?;
    let root = playthrough::fb::get_root_as_playthrough_root(data);
    for item in root.items().unwrap() {
        println!("{}", item.location().unwrap().name().unwrap());
    }

    //achievements::generate();
    //weapons_shields::generate();
    //armor::generate();
    //trades::generate();
    //soul_types::generate();
    Ok(())
}
