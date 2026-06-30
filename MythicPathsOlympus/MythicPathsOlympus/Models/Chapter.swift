import Foundation

/// One panel of an illustrated chapter: a single image with a line of narration.
struct StoryPanel: Identifiable, Codable {
    let id: String
    /// Who's speaking — e.g. "Hermes" shows the guide badge; nil is plain narration.
    let speaker: String?
    let text: String
    /// Asset name for the illustration (e.g. "chapter1-01"). Falls back to a
    /// placeholder until the real art is added, so the chapter is playable now.
    let image: String
    /// If set (e.g. "hermes"), this panel shows the animated guide full-bleed
    /// instead of a static illustration. Looks for "<guide>-idle/-talk/-blink".
    let guide: String?
}

/// A "Learn" chapter: a sequence of illustrated panels that ends by handing off
/// to the matching trivia category. This is the Learn → Quiz half of the loop.
struct Chapter: Identifiable, Codable {
    let id: String
    let title: String
    let unit: String
    /// Must match a `TriviaQuestion.category` so the end-of-chapter quiz lines up.
    let quizCategory: String
    /// Optional: specific question IDs to quiz on, so the end-of-chapter quiz only
    /// asks what this chapter actually taught. Falls back to the whole category.
    let quizQuestionIDs: [String]?
    let panels: [StoryPanel]
}
