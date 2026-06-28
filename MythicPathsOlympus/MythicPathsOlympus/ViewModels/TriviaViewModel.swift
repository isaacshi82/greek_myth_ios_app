import Foundation
import Combine

/// Holds all the state for one run through the trivia quiz: which question we're
/// on, the score so far, and whether the player has answered the current one.
///
/// Keeping the game logic here (instead of inside the View) makes it easy to
/// reason about and test, and keeps the View focused on how things look.
final class TriviaViewModel: ObservableObject {
    @Published private(set) var questions: [TriviaQuestion]
    @Published private(set) var currentIndex = 0
    @Published private(set) var score = 0
    /// The answer index the player tapped for the current question, or nil if unanswered.
    @Published private(set) var selectedIndex: Int? = nil
    @Published private(set) var isFinished = false

    init(questions: [TriviaQuestion]? = nil) {
        // Load from the bundle by default; allow injection for previews/tests.
        let loaded = questions ?? Bundle.main.decode([TriviaQuestion].self, from: "trivia_questions.json")
        self.questions = loaded.shuffled()
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

    /// Start over with a freshly shuffled deck.
    func restart() {
        questions.shuffle()
        currentIndex = 0
        score = 0
        selectedIndex = nil
        isFinished = false
    }
}
