use std::path::Path;

fn main() {
    // println!("cargo:rerun-if-changed=../schema/playthrough.fbs");
    flatc_rust::run(flatc_rust::Args {
        inputs: &[Path::new("../schema/playthrough.fbs")],
        out_dir: Path::new("target/flatbuffers/"),
        ..Default::default()
    })
    .expect("flatc");
}
