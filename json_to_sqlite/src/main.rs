use rusqlite::{params, Connection, Result};
use serde_json::Value;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    //achievements::transmute("./jsons/achievements.json")?;
    //weapshields::transmute("./jsons/weapons_and_shields.json")?;
    //armor::transmute("./jsons/armor.json")?;
    trades::transmute("./jsons/trades.json")?;
    //playthrough::transmute("jsons/playthrough.json");
    Ok(())
}

use std::path::Path;
use std::path::PathBuf;

mod trades {
    use super::*;

    pub fn transmute<T: Into<PathBuf>>(json_path: T) -> Result<(), Box<dyn std::error::Error>> {
        let json_path: PathBuf = json_path.into();
        let stem = json_path.file_stem().unwrap();
        let tmp_path = Path::new("/tmp/").join(json_path.file_name().unwrap());
        std::fs::remove_file(&tmp_path).ok();
        let conn = Connection::open(&tmp_path)?;
        conn.execute(
            "CREATE TABLE trades (
                        trade_id     INTEGER,
                        is_checked      BOOL
                      )",
            params![],
        )?;
        let root: Value =
            serde_json::from_str(&std::fs::read_to_string(&json_path).unwrap()).unwrap();
        let mut insert_trade = conn
            .prepare("INSERT INTO trades (trade_id, is_checked) VALUES (?1, ?2)")
            .unwrap();

        let trades = root.as_array().unwrap();
        for (trade_idx, _trade) in trades.into_iter().enumerate() {
            insert_trade
                .execute(params![trade_idx as u32, false])
                .unwrap();
        }
        std::fs::copy(tmp_path, Path::new("./sqlites/").join(stem)).unwrap();
        Ok(())
    }
}

mod armor {
    use super::*;

    pub fn transmute<T: Into<PathBuf>>(json_path: T) -> Result<(), Box<dyn std::error::Error>> {
        let json_path: PathBuf = json_path.into();
        let stem = json_path.file_stem().unwrap();
        let tmp_path = Path::new("/tmp/").join(json_path.file_name().unwrap());
        std::fs::remove_file(&tmp_path).ok();
        let conn = Connection::open(&tmp_path)?;
        conn.execute(
            "CREATE TABLE armor_tasks (
                        abs_task_id     INTEGER PRIMARY KEY,
                        task_id         INTEGER,
                        cat_id           INTEGER,
                        is_checked      BOOL
                      )",
            params![],
        )?;
        let root: Value =
            serde_json::from_str(&std::fs::read_to_string(&json_path).unwrap()).unwrap();
        let mut insert_tasks = conn
            .prepare("INSERT INTO armor_tasks (task_id, cat_id, is_checked) VALUES (?1, ?2, ?3)")
            .unwrap();

        let categories = root.as_array().unwrap();
        for (cat_idx, cat) in categories.into_iter().enumerate() {
            for (task_idx, _val) in cat["gear_names"]
                .as_array()
                .unwrap()
                .into_iter()
                .enumerate()
            {
                insert_tasks
                    .execute(params![task_idx as u32, cat_idx as u32, false])
                    .unwrap();
            }
        }
        std::fs::copy(tmp_path, Path::new("./sqlites/").join(stem)).unwrap();
        Ok(())
    }
}

mod weapshields {
    use super::*;

    pub fn transmute<T: Into<PathBuf>>(json_path: T) -> Result<(), Box<dyn std::error::Error>> {
        let json_path: PathBuf = json_path.into();
        let stem = json_path.file_stem().unwrap();
        let tmp_path = Path::new("/tmp/").join(json_path.file_name().unwrap());
        std::fs::remove_file(&tmp_path).ok();
        let conn = Connection::open(&tmp_path)?;
        conn.execute(
            "CREATE TABLE ws_tasks (
                        abs_task_id     INTEGER PRIMARY KEY,
                        task_id         INTEGER,
                        cat_id           INTEGER,
                        is_checked      BOOL
                      )",
            params![],
        )?;
        let root: Value =
            serde_json::from_str(&std::fs::read_to_string(&json_path).unwrap()).unwrap();
        let mut insert_tasks = conn
            .prepare("INSERT INTO ws_tasks (task_id, cat_id, is_checked) VALUES (?1, ?2, ?3)")
            .unwrap();

        let categories = root.as_array().unwrap();
        for (cat_idx, cat) in categories.into_iter().enumerate() {
            for (task_idx, _val) in cat["item_names"]
                .as_array()
                .unwrap()
                .into_iter()
                .enumerate()
            {
                insert_tasks
                    .execute(params![task_idx as u32, cat_idx as u32, false])
                    .unwrap();
            }
        }
        std::fs::copy(tmp_path, Path::new("./sqlites/").join(stem)).unwrap();
        Ok(())
    }
}

mod achievements {
    use super::*;

    pub fn transmute<T: Into<PathBuf>>(json_path: T) -> Result<(), Box<dyn std::error::Error>> {
        let json_path: PathBuf = json_path.into();
        let stem = json_path.file_stem().unwrap();
        let tmp_path = Path::new("/tmp/").join(json_path.file_name().unwrap());
        std::fs::remove_file(&tmp_path).ok();
        let conn = Connection::open(&tmp_path)?;
        conn.execute(
            "CREATE TABLE ach_tasks (
                        abs_task_id     INTEGER PRIMARY KEY,
                        task_id         INTEGER,
                        ach_id          INTEGER,
                        is_checked      BOOL
                      )",
            params![],
        )?;
        let root: Value =
            serde_json::from_str(&std::fs::read_to_string(&json_path).unwrap()).unwrap();
        let mut insert_tasks = conn
            .prepare_cached(
                "INSERT INTO ach_tasks (task_id, ach_id, is_checked) VALUES (?1, ?2, ?3)",
            )
            .unwrap();

        let categories = root.as_array().unwrap();
        for (ach_idx, cat) in categories.into_iter().enumerate() {
            for (task_idx, _val) in cat["tasks"].as_array().unwrap().into_iter().enumerate() {
                insert_tasks
                    .execute(params![task_idx as u32, ach_idx as u32, false])
                    .unwrap();
            }
        }
        std::fs::copy(tmp_path, Path::new("./sqlites/").join(stem)).unwrap();
        Ok(())
    }
}

mod playthrough {
    use super::*;
    pub fn transmute<T: Into<PathBuf>>(json_path: T) {
        let json_path: PathBuf = json_path.into();
        let stem = json_path.file_stem().unwrap();
        let tmp_path = Path::new("/tmp/").join(json_path.file_stem().unwrap());
        std::fs::remove_file(&tmp_path).ok();
        let conn = Connection::open(&tmp_path).unwrap();
        conn.execute(
            "CREATE TABLE pt_tasks (
                      abs_task_id              INTEGER PRIMARY KEY,
                      task_id         INTEGER,
                      location_id     INTEGER,
                      is_checked      BOOL
                      )",
            params![],
        )
        .unwrap();
        let root: Value =
            serde_json::from_str(&std::fs::read_to_string(&json_path).unwrap()).unwrap();
        let mut insert_tasks = conn
            .prepare("INSERT INTO pt_tasks (task_id, location_id, is_checked) VALUES (?1, ?2, ?3)")
            .unwrap();

        let categories = root.as_array().unwrap();
        for (loc_idx, cat) in categories.into_iter().enumerate() {
            for (task_idx, _task) in cat["actions"].as_array().unwrap().into_iter().enumerate() {
                insert_tasks
                    .execute(params![task_idx as u32, loc_idx as u32, false])
                    .unwrap();
            }
        }
        drop(insert_tasks);
        conn.close().unwrap();
        let abs_path = Path::new("./sqlites/").canonicalize().unwrap().join(stem);
        std::fs::copy(tmp_path, abs_path).unwrap();
    }
}
