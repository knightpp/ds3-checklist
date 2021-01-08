use std::path::Path;

fn main() {
    println!("cargo:rerun-if-changed=../schema/playthrough.fbs");
    println!("cargo:rerun-if-changed=../schema/achievements.fbs");
    println!("cargo:rerun-if-changed=../schema/trades.fbs");
    println!("cargo:rerun-if-changed=../schema/armor.fbs");
    println!("cargo:rerun-if-changed=../schema/souls.fbs");
    println!("cargo:rerun-if-changed=../schema/weapons_and_shields.fbs");
    flatc_rust::run(flatc_rust::Args {
        inputs: &[
            Path::new("../schema/playthrough.fbs"),
            Path::new("../schema/achievements.fbs"),
            Path::new("../schema/trades.fbs"),
            Path::new("../schema/armor.fbs"),
            Path::new("../schema/souls.fbs"),
            Path::new("../schema/weapons_and_shields.fbs"),
        ],
        out_dir: Path::new("target/flatbuffers/"),
        ..Default::default()
    })
    .expect("flatc");
}
