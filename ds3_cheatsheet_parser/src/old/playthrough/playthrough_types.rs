use serde::{Deserialize, Serialize};

#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
pub enum Type {
    Quests(Quests),
    Upgrades(Upgrades),
    Achievements(Achievements),
    Gear(Gear),
    Materials(Materials),
    Others(Others),
    None,
}

#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
pub enum Others {
    Covenants,
    MiscItems,
}
#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
pub enum Materials {
    Titanite,
    Gems,
}
#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
pub enum Gear {
    Weapons,
    Armor,
}
#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
pub enum Achievements {
    Gestures,
    Sorceries,
    Pyromancies,
    Miracles,
    Rings,
}
#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
pub enum Upgrades {
    EstusShards,
    UndeadBoneShards,
    ScrollsOrTomes,
    Coals,
    Ashes,
}
#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
pub enum Quests {
    Bosses,
    NPCs,
}

#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
pub enum ContentFrom{
    BaseGame,
    BaseGameOptional,
    Dlc(Dlc),
}

#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
pub enum Dlc{
    AshesOfAriandel,
    TheRingedCity
}
#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
pub enum Journey{
    /// First playthrough
    NG,
    /// Second playthrough
    NGp,
    /// Third playthrough
    NGpp,
}