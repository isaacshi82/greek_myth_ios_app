import SwiftUI

/// First-launch intro: Hermes "summons" the player, then hands off to the menu.
/// Reuses the animated GuideSpeaker so the intro matches the in-app guide.
struct WelcomeView: View {
    let onBegin: () -> Void

    /// The summons, delivered a beat at a time (tap to advance).
    private let beats = [
        "Whoa — there you are! Finally. The gods sent me to find you.",
        "The old stories are fading… and the gods need someone sharp to learn them and keep them alive. They picked YOU.",
        "I'm Hermes — messenger, trickster, and your guide. Stick with me and you'll know the gods better than they know themselves. Ready?"
    ]

    @State private var beat = 0
    @State private var entered = false

    private var isLast: Bool { beat == beats.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            // Hermes waves hello during the greeting beat, then talks.
            Group {
                if beat == 0 {
                    GuideFrameImage(name: "hermes-wave", placeholderBase: "hermes")
                } else {
                    GuideSpeaker(base: "hermes")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .scaleEffect(entered ? 1 : 0.85)
            .opacity(entered ? 1 : 0)

            dialogue
        }
        .contentShape(Rectangle())
        .onTapGesture { if !isLast { withAnimation { beat += 1 } } }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) { entered = true }
        }
    }

    private var dialogue: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "paperplane.fill")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(7)
                    .background(
                        LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: Circle()
                    )
                Text("Hermes")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.purple)
            }

            Text(beats[beat])
                .font(.title3)
                .fixedSize(horizontal: false, vertical: true)
                .id(beat)
                .transition(.opacity)

            if isLast {
                Button(action: onBegin) {
                    Text("Begin Your Journey")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
            } else {
                HStack {
                    Spacer()
                    Text("Tap to continue ›")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
    }
}

#Preview {
    WelcomeView(onBegin: {})
}
