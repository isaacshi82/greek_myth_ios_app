import SwiftUI

/// Filter the quiz by category and difficulty before starting.
struct TriviaConfig: Hashable {
    let category: String?
    let difficulty: String?
}

struct TriviaSetupView: View {
    @State private var category: String? = nil
    @State private var difficulty: String? = nil

    /// How many questions match the current filters.
    private var matchCount: Int {
        QuestionBank.filtered(category: category, difficulty: difficulty).count
    }
    /// A round is capped at 10 questions (or fewer if the pool is smaller).
    private var roundLength: Int { min(matchCount, 10) }

    var body: some View {
        Form {
            Section("Category") {
                Picker("Category", selection: $category) {
                    Text("All Categories").tag(String?.none)
                    ForEach(QuestionBank.categories, id: \.self) { name in
                        Text(name).tag(String?.some(name))
                    }
                }
            }

            Section("Difficulty") {
                Picker("Difficulty", selection: $difficulty) {
                    Text("All Levels").tag(String?.none)
                    ForEach(QuestionBank.difficulties, id: \.self) { level in
                        Text(level.capitalized).tag(String?.some(level))
                    }
                }
            }

            Section {
                NavigationLink(value: TriviaConfig(category: category, difficulty: difficulty)) {
                    HStack {
                        Text("Start Quiz").font(.headline)
                        Spacer()
                        Text("\(roundLength) question\(roundLength == 1 ? "" : "s")")
                            .foregroundStyle(.secondary)
                    }
                }
                .disabled(matchCount == 0)
            } footer: {
                if matchCount == 0 {
                    Text("No questions match this combination yet.")
                } else if matchCount > roundLength {
                    Text("\(roundLength) random questions drawn from \(matchCount) available.")
                }
            }
        }
        .navigationTitle("Trivia Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: TriviaConfig.self) { config in
            TriviaView(category: config.category, difficulty: config.difficulty)
        }
    }
}

#Preview {
    NavigationStack {
        TriviaSetupView()
    }
}
