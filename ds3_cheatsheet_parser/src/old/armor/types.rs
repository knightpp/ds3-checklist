use serde::{Deserialize, Serialize};


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ArmorCategory {
    pub(super) category: String,
    pub(super) gear_names: Vec<String>,
}