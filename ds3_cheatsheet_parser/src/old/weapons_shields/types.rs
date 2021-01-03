use serde::{Deserialize, Serialize};


// pub(super) enum Category {
//     Daggers,
//     #[serde(rename = "Straight Swords")]
//     StraightSwords,
// }
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WeaponCategory {
    pub(super) category: String,
    pub(super) weapon_names: Vec<String>,
}


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ShieldCategory {
    pub(super) category: String,
    pub(super) shield_names: Vec<String>,
}