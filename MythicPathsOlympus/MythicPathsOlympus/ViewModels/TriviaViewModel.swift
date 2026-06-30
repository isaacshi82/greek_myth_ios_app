import Foundation
import Combine

/// Holds all the state for one run through the trivia quiz: which question we're
/// on, the score so far, and whether the player has answered the current one.
///
/// Keeping the game logic here (instead of inside the View) makes it easy to
/// reason about and test, and keeps the View focused on how things look.
final class TriviaViewModel: ObservableObject {
    /// The full pool of questions matching the chosen filters; a round is drawn from this.
    private let pool: [TriviaQuestion]
    /// Maximum number of questions in a single round.
    private let roundSize: Int

    @Published private(set) var questions: [TriviaQuestion]   // the current round
    @Published private(set) var currentIndex = 0
    @Published private(set) var score = 0
    /// The answer index the player tapped for the current question, or nil if unanswered.
    @Published private(set) var selectedIndex: Int? = nil
    @Published private(set) var isFinished = false

    /// Build a quiz, optionally filtered by category and/or difficulty.
    /// Pass `pool` directly for previews/tests.
    init(category: String? = nil, difficulty: String? = nil, roundSize: Int = 10, pool: [TriviaQuestion]? = nil) {
        let source = pool ?? QuestionBank.filtered(category: category, difficulty: difficulty)
        self.pool = source
        self.roundSize = roundSize
        self.questions = Array(source.shuffled().prefix(roundSize))
        // Defensive: an empty pool can't be played, so treat it as already finished.
        self.isFinished = self.questions.isEmpty
    }

    var currentQuestion: TriviaQuestion { questions[currentIndex] }
    var questionNumber: Int { currentIndex + 1 }
    var totalQuestions: Int { questions.count }
    var hasAnswered: Bool { selectedIndex != nil }
    var isLastQuestion: Bool { currentIndex == questions.count - 1 }

    /// Record the player's answer. Ignored if they've already answered this question.
    func select(_ index: Int) {
        guard selectedIndex == nil else { return }
        selectedIndex = index
        if index == currentQuestion.correctIndex {
            score += 1
        }
    }

    /// Advance to the next question, or finish the quiz if we're on the last one.
    func advance() {
        guard hasAnswered else { return }
        if isLastQuestion {
            isFinished = true
        } else {
            currentIndex += 1
            selectedIndex = nil
        }
    }

    /// Start over with a freshly drawn, shuffled round from the same pool.
    func restart() {
        questions = Array(pool.shuffled().prefix(roundSize))
        currentIndex = 0
        score = 0
        selectedIndex = nil
        isFinished = questions.isEmpty
    }
}
