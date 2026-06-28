import Foundation

/// A single multiple-choice trivia question.
///
/// Questions live in `Data/trivia_questions.json` so we can add, edit, and
/// fact-check content without ever touching Swift code. Every question carries
/// a `source` so each answer is traceable to a real reference.
struct TriviaQuestion: Identifiable, Codable {
    let id: String
    let question: String
    let answers: [String]      // exactly 4 options
    let correctIndex: Int      // 0-based index into `answers`
    let explanation: String    // shown after the player answers
    let category: String       // e.g. "Olympians", "Heroes", "Monsters", "Myths & Stories"
    let difficulty: String     // "easy" | "medium" | "hard"
    let source: String         // citation for the correct answer

    /// The text of the correct answer.
    var correctAnswer: String { answers[correctIndex] }
}
