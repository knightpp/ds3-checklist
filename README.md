# DS3 checklist

## I have no time to work on this project and it is useful in the current shape ⚠️⚠️⚠️

[Google Play link](https://play.google.com/store/apps/details?id=io.knightpp.ds3_checklist)

## Translations

This project uses Crowdin to manage translations. [Join us!](https://crowdin.com/project/darksouls-3-checklist)

[![chart](https://badges.awesome-crowdin.com/translation-13072808-435288.png)](https://crowdin.com/project/darksouls-3-checklist)

## Updating i18n files

To generate run:

```shell
cd ds3_cheatsheet_parser/
cargo run
```

After adding new translations, please update ds3_cheatsheet_parser/src/main.rs:

```rust
    const SUPPORTED_LANGS: &[&'static str] = &["en", "fr", "it", "pl", "uk"];
```
