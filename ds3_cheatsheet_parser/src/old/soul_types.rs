use serde::{Deserialize, Serialize};

use crate::strum::IntoEnumIterator;

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Soul {
    name: SoulType,
    souls: u32,
}

pub fn generate() {
    let s = SoulType::iter()
        .map(|st| Soul {
            souls: st.souls(),
            name: st,
        })
        .collect::<Vec<_>>();

    std::fs::write(
        "database/soul_prices.json",
        serde_json::to_string_pretty(&s).unwrap(),
    )
    .unwrap();
}

#[derive(EnumIter, Debug, Copy, Clone, Serialize, Deserialize)]
pub enum SoulType {
    #[serde(rename = "Fading Soul")]
    FadingSoul,

    #[serde(rename = "Soul of a Deserted Corpse")]
    SoulOfADesertedCorpse,

    #[serde(rename = "Large soul of a Deserted Corpse")]
    LargeSoulOfADesertedCorpse,

    #[serde(rename = "Soul of a Proud Paladin")]
    SoulOfAProudPaladin,

    #[serde(rename = "Soul of an Unknown Traveler")]
    SoulOfanUnknownTraveler,

    #[serde(rename = "Large Soul of an Unknown Traveler")]
    LargeSoulOfAnUnknownTraveler,

    #[serde(rename = "Large Soul of a Proud Paladin")]
    LargeSoulOfAProudPaladin,

    #[serde(rename = "Sovereignless Soul")]
    SovereignlessSoul,

    #[serde(rename = "Soul of an Intrepid Hero")]
    SoulOfAnIntrepidHero,

    #[serde(rename = "Soul of a Nameless Soldier")]
    SoulOfANamelessSoldier,

    #[serde(rename = "Large soul of an Intrepid Hero")]
    LargesoulOfAnIntrepidHero,

    #[serde(rename = "Large Soul of a Nameless Soldier")]
    LargeSoulOfANamelessSoldier,

    #[serde(rename = "Soul of a Seasoned Warrior")]
    SoulOfASeasonedWarrior,

    #[serde(rename = "Soul of a Weary Warrior")]
    SoulOfAWearyWarrior,

    #[serde(rename = "Large Soul of a Seasoned Warrior")]
    LargeSoulOfASeasonedWarrior,

    #[serde(rename = "Large Soul of a Weary Warrior")]
    LargeSoulOfAWearyWarrior,

    #[serde(rename = "Soul of a Crestfallen Knight")]
    SoulOfACrestfallenKnight,

    #[serde(rename = "Soul of an Old Hand")]
    SoulOfAnOldHand,

    #[serde(rename = "Large Soul of a Crestfallen Knight")]
    LargeSoulOfACrestfallenKnight,

    #[serde(rename = "Soul of a Venerable Old Hand")]
    SoulOfAVenerableOldHand,

    #[serde(rename = "Soul of a Champion")]
    SoulOfAChampion,

    #[serde(rename = "Soul of a Great Champion")]
    SoulOfAGreatChampion,
}

impl SoulType {
    pub fn souls(&self) -> u32 {
        match self {
            SoulType::FadingSoul => 50,
            SoulType::SoulOfADesertedCorpse => 200,
            SoulType::LargeSoulOfADesertedCorpse => 400,
            SoulType::SoulOfAProudPaladin => 500,
            SoulType::SoulOfanUnknownTraveler => 800,
            SoulType::LargeSoulOfAnUnknownTraveler => 1_000,
            SoulType::LargeSoulOfAProudPaladin => 1_000,
            SoulType::SovereignlessSoul => 2_000,
            SoulType::SoulOfAnIntrepidHero => 2_000,
            SoulType::SoulOfANamelessSoldier => 2_000,
            SoulType::LargesoulOfAnIntrepidHero => 2_500,
            SoulType::LargeSoulOfANamelessSoldier => 3_000,
            SoulType::SoulOfASeasonedWarrior => 5_000,
            SoulType::SoulOfAWearyWarrior => 5_000,
            SoulType::LargeSoulOfASeasonedWarrior => 7_500,
            SoulType::LargeSoulOfAWearyWarrior => 8_000,
            SoulType::SoulOfACrestfallenKnight => 10_000,
            SoulType::SoulOfAnOldHand => 12_500,
            SoulType::LargeSoulOfACrestfallenKnight => 20_000,
            SoulType::SoulOfAVenerableOldHand => 20_000,
            SoulType::SoulOfAChampion => 25_000,
            SoulType::SoulOfAGreatChampion => 50_000,
        }
    }
}
