import Foundation

/// The app's question bank, loaded once from the bundle, plus helpers for
/// filtering by category and difficulty. Centralizing this keeps the loading
/// logic in one place for both the setup screen and the quiz.
enum QuestionBank {
    /// Every question, loaded a single time.
    static let all: [TriviaQuestion] = Bundle.main.decode([TriviaQuestion].self, from: "trivia_questions.json")

    /// Distinct categories, in the order they first appear in the JSON.
    static let categories: [String] = {
        var seen = Set<String>()
        return all.compactMap { seen.insert($0.category).inserted ? $0.category : nil }
    }()

    /// Difficulty levels in natural (easy → hard) order.
    static let difficulties: [String] = ["easy", "medium", "hard"]

    /// Questions matching the given filters. A `nil` filter means "any".
    static func filtered(category: String?, difficulty: String?) -> [TriviaQuestion] {
        all.filter { question in
            (category == nil || question.category == category) &&
            (difficulty == nil || question.difficulty == difficulty)
        }
    }
}
