use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub(super) struct Achievement{
    pub(super) name : String,
    pub(super) tasks : Vec<Task>,
    //description : String,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
pub(super) struct Task{
    pub(super) item_name : String,
    pub(super) description : String,
    pub(super) available_from : Journey,
}


#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
pub(super) enum Journey{
    /// First playthrough
    NG,
    /// Second playthrough
    NGp,
    /// Third playthrough
    NGpp,
}
