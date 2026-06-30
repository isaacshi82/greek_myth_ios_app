import Foundation
import Combine

/// Tracks the player's progress (best trivia scores, chapters read, lifetime
/// correct answers) and decides which collectibles are unlocked. Persists to
/// UserDefaults so the collection survives app launches.
///
/// Use the shared instance everywhere: record from gameplay, observe in the UI.
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    /// The persisted shape of all progress. Kept as one Codable blob for simplicity.
    private struct State: Codable {
        var bestScores: [String: Int] = [:]      // category -> best percent (0…100)
        var completedChapters: Set<String> = []
        var totalCorrect = 0
        var quizzesPlayed = 0
        var hadPerfectRound = false
    }

    @Published private var state: State { didSet { save() } }

    private let defaultsKey = "progress.v1"

    private init() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode(State.self, from: data) {
            state = decoded
        } else {
            state = State()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    // MARK: - Recording progress

    /// Record one finished quiz round. `category` is nil for an "all categories" run.
    func recordQuiz(category: String?, score: Int, total: Int) {
        guard total > 0 else { return }
        var s = state
        s.quizzesPlayed += 1
        s.totalCorrect += score
        let percent = Int((Double(score) / Double(total) * 100).rounded())
        if percent >= 100 { s.hadPerfectRound = true }
        if let category {
            s.bestScores[category] = max(s.bestScores[category] ?? 0, percent)
        }
        state = s
    }

    /// Mark a Learn chapter as read to the end.
    func completeChapter(_ id: String) {
        guard !state.completedChapters.contains(id) else { return }
        state.completedChapters.insert(id)
    }

    // MARK: - Read access

    var totalCorrect: Int { state.totalCorrect }
    var quizzesPlayed: Int { state.quizzesPlayed }
    func bestScore(in category: String) -> Int { state.bestScores[category] ?? 0 }

    var collectedCount: Int { Pantheon.all.filter { isUnlocked($0) }.count }

    func isUnlocked(_ c: Collectible) -> Bool {
        switch c.unlock {
        case .intro: return true
        case .categoryScore(let cat, let min): return bestScore(in: cat) >= min
        case .completeChapter(let id): return state.completedChapters.contains(id)
        case .totalCorrect(let n): return state.totalCorrect >= n
        case .perfectRound: return state.hadPerfectRound
        }
    }

    /// A short "how to earn it" hint and optional 0…1 progress for a locked card.
    func hint(for c: Collectible) -> (text: String, progress: Double?) {
        switch c.unlock {
        case .intro:
            return ("Your guide through the myths", nil)
        case .categoryScore(let cat, let min):
            let best = bestScore(in: cat)
            return ("Score \(min)% in \(cat) trivia (best: \(best)%)", Double(best) / Double(min))
        case .completeChapter(let id):
            let title = ChapterLibrary.all.first { $0.id == id }?.title ?? "a Learn chapter"
            return ("Finish the chapter “\(title)”", nil)
        case .totalCorrect(let n):
            return ("Answer \(n) questions correctly (\(min(totalCorrect, n))/\(n))", Double(totalCorrect) / Double(n))
        case .perfectRound:
            return ("Score 100% in any quiz round", nil)
        }
    }

#if DEBUG
    /// Reset everything (used only for previews/testing).
    func resetForTesting() { state = State() }
#endif
}
