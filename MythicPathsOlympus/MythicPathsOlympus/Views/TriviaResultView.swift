import SwiftUI

struct TriviaResultView: View {
    let score: Int
    let total: Int
    let onPlayAgain: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var percent: Double { total == 0 ? 0 : Double(score) / Double(total) }

    /// A themed rank based on how the player did.
    private var verdict: (title: String, subtitle: String, symbol: String) {
        switch percent {
        case 0.9...:   return ("Worthy of Olympus!", "The gods themselves are impressed.", "crown.fill")
        case 0.7..<0.9: return ("A True Hero", "Your name will echo in the halls of legend.", "laurel.leading")
        case 0.5..<0.7: return ("Promising Mortal", "Keep training — greatness is within reach.", "figure.walk")
        default:        return ("Back to the Scrolls", "Even Heracles had to study. Try again!", "book.fill")
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: verdict.symbol)
                .font(.system(size: 64))
                .foregroundStyle(.yellow)

            Text(verdict.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("You scored \(score) out of \(total)")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(verdict.subtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    onPlayAgain()
                } label: {
                    Text("Play Again")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Back to Menu")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
        .padding()
    }
}

#Preview {
    TriviaResultView(score: 9, total: 12, onPlayAgain: {})
}
