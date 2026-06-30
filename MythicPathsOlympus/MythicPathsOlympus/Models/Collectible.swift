import SwiftUI

/// A mythological figure the player can collect by playing. Until real art is
/// generated, cards render from `colors` + `emoji`; drop an asset named
/// `imageName` (e.g. "god-zeus") and the card uses it automatically.
struct Collectible: Identifiable {
    let id: String
    let name: String
    /// A short epithet shown under the name, e.g. "King of Olympus".
    let epithet: String
    /// A one-word realm/role tag for the card chip, e.g. "Olympian".
    let domain: String
    /// A kid-friendly blurb shown on the detail card once unlocked.
    let lore: String
    /// Signature emoji used as the card motif until art exists.
    let emoji: String
    /// Asset name for future illustrated art (optional today).
    let imageName: String
    /// Two-color gradient for the card background.
    let colors: [Color]
    /// What the player must do to earn this figure.
    let unlock: Unlock
}

/// How a collectible is earned. Every rule maps to something already tracked in
/// `ProgressStore`, so the collection grows naturally as the player plays.
enum Unlock {
    /// Unlocked from the start (the guide).
    case intro
    /// Reach `minPercent` best score in a trivia category.
    case categoryScore(String, minPercent: Int)
    /// Read a Learn chapter to the end.
    case completeChapter(String)
    /// Answer this many questions correctly across all play.
    case totalCorrect(Int)
    /// Score 100% in any single quiz round.
    case perfectRound
}

/// The fixed roster of collectible figures.
enum Pantheon {
    static let all: [Collectible] = [
        Collectible(
            id: "hermes", name: "Hermes", epithet: "Messenger of the Gods", domain: "Olympian",
            lore: "Swift-footed trickster and guide of travelers, Hermes carries messages between the gods and leads souls on their journeys. He's your guide through these myths.",
            emoji: "🪽", imageName: "god-hermes",
            colors: [.teal, .indigo], unlock: .intro
        ),
        Collectible(
            id: "zeus", name: "Zeus", epithet: "King of Olympus", domain: "Olympian",
            lore: "Lord of the sky and ruler of the gods, Zeus wields the thunderbolt forged by the Cyclopes. He led the war against the Titans and divided the world among his brothers.",
            emoji: "⚡️", imageName: "god-zeus",
            colors: [.yellow, .orange], unlock: .categoryScore("Olympians", minPercent: 70)
        ),
        Collectible(
            id: "poseidon", name: "Poseidon", epithet: "Lord of the Sea", domain: "Olympian",
            lore: "Brother of Zeus and master of the oceans, Poseidon strikes the earth with his trident to raise storms and earthquakes. Sailors prayed to him for safe passage.",
            emoji: "🔱", imageName: "god-poseidon",
            colors: [.blue, .teal], unlock: .perfectRound
        ),
        Collectible(
            id: "hades", name: "Hades", epithet: "Lord of the Dead", domain: "Underworld",
            lore: "Eldest brother of Zeus, Hades rules the realm of the dead with a quiet, grim authority. He is wealthy keeper of the earth's hidden riches — and rarely leaves his kingdom.",
            emoji: "💀", imageName: "god-hades",
            colors: [.indigo, .black], unlock: .categoryScore("The Underworld", minPercent: 70)
        ),
        Collectible(
            id: "persephone", name: "Persephone", epithet: "Queen of the Underworld", domain: "Underworld",
            lore: "Daughter of Demeter and queen at Hades' side, Persephone spends part of the year below and part above — and her return each spring brings the world back to bloom.",
            emoji: "🌸", imageName: "god-persephone",
            colors: [.pink, .purple], unlock: .totalCorrect(60)
        ),
        Collectible(
            id: "athena", name: "Athena", epithet: "Goddess of Wisdom", domain: "Olympian",
            lore: "Born fully armored from the head of Zeus, Athena is goddess of wisdom, strategy, and craft. The city of Athens bears her name, and the owl is her sacred companion.",
            emoji: "🦉", imageName: "god-athena",
            colors: [.gray, .blue], unlock: .totalCorrect(30)
        ),
        Collectible(
            id: "heracles", name: "Heracles", epithet: "The Strongest Hero", domain: "Hero",
            lore: "Son of Zeus and the greatest of mortal heroes, Heracles performed twelve impossible labors — from slaying the Nemean Lion to capturing Cerberus itself.",
            emoji: "💪", imageName: "hero-heracles",
            colors: [.orange, .red], unlock: .categoryScore("Heroes", minPercent: 70)
        ),
        Collectible(
            id: "medusa", name: "Medusa", epithet: "The Gorgon", domain: "Monster",
            lore: "A monster with serpents for hair whose gaze turned the living to stone. The hero Perseus slew her by watching her reflection in his polished shield.",
            emoji: "🐍", imageName: "monster-medusa",
            colors: [.green, .black], unlock: .categoryScore("Monsters", minPercent: 70)
        ),
        Collectible(
            id: "cronus", name: "Cronus", epithet: "The Titan King", domain: "Titan",
            lore: "Youngest of the Titans, Cronus overthrew his own father to rule the Golden Age — then swallowed his children to escape a prophecy. His son Zeus proved that prophecy true.",
            emoji: "⏳", imageName: "titan-cronus",
            colors: [.brown, .gray], unlock: .completeChapter("ch1")
        ),
        Collectible(
            id: "gaia", name: "Gaia", epithet: "Mother Earth", domain: "Primordial",
            lore: "The Earth herself, born near the dawn of all things. Gaia gave rise to the sky, the sea, and the Titans — the great-grandmother of the gods.",
            emoji: "🌍", imageName: "primordial-gaia",
            colors: [.green, .brown], unlock: .completeChapter("ch1")
        )
    ]
}
