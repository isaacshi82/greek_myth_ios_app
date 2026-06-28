import SwiftUI

struct TriviaView: View {
    @StateObject private var model: TriviaViewModel

    init(category: String? = nil, difficulty: String? = nil) {
        _model = StateObject(wrappedValue: TriviaViewModel(category: category, difficulty: difficulty))
    }

    var body: some View {
        Group {
            if model.isFinished {
                TriviaResultView(
                    score: model.score,
                    total: model.totalQuestions,
                    onPlayAgain: { model.restart() }
                )
            } else {
                quiz
            }
        }
        .navigationTitle("Trivia Challenge")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var quiz: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Progress + running score
            HStack {
                Text("Question \(model.questionNumber) of \(model.totalQuestions)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Label("\(model.score)", systemImage: "laurel.leading")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: Double(model.questionNumber), total: Double(model.totalQuestions))
                .tint(.accentColor)

            // Question text
            Text(model.currentQuestion.question)
                .font(.title3.weight(.bold))
                .fixedSize(horizontal: false, vertical: true)

            // Answer buttons
            VStack(spacing: 12) {
                ForEach(Array(model.currentQuestion.answers.enumerated()), id: \.offset) { index, answer in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { model.select(index) }
                    } label: {
                        Text(answer)
                            .font(.body.weight(.medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(backgroundColor(for: index), in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(foregroundColor(for: index))
                    }
                    .disabled(model.hasAnswered)
                }
            }

            // Explanation, shown after answering
            if model.hasAnswered {
                VStack(alignment: .leading, spacing: 6) {
                    Text(model.selectedIndex == model.currentQuestion.correctIndex ? "Correct!" : "Not quite.")
                        .font(.headline)
                        .foregroundStyle(model.selectedIndex == model.currentQuestion.correctIndex ? .green : .red)
                    Text(model.currentQuestion.explanation)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("Source: \(model.currentQuestion.source)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                .transition(.opacity)
            }

            Spacer()

            // Next / See Results
            if model.hasAnswered {
                Button {
                    withAnimation { model.advance() }
                } label: {
                    Text(model.isLastQuestion ? "See Results" : "Next Question")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
            }
        }
        .padding()
    }

    // MARK: - Answer button styling

    /// After answering: correct answer is green; a wrong pick is red; the rest fade.
    private func backgroundColor(for index: Int) -> Color {
        guard model.hasAnswered else { return Color(.secondarySystemBackground) }
        if index == model.currentQuestion.correctIndex { return .green }
        if index == model.selectedIndex { return .red }
        return Color(.secondarySystemBackground).opacity(0.5)
    }

    private func foregroundColor(for index: Int) -> Color {
        guard model.hasAnswered else { return .primary }
        if index == model.currentQuestion.correctIndex || index == model.selectedIndex { return .white }
        return .secondary
    }
}

#Preview {
    NavigationStack {
        TriviaView()
    }
}
