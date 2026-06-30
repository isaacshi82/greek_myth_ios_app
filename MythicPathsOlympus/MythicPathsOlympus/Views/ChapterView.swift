import SwiftUI

/// Plays one illustrated chapter in landscape: full-bleed art (with a slow Ken
/// Burns drift) and narration floating over the bottom in a glass card.
/// Tap anywhere to advance with a crossfade, ending in a button to the quiz.
struct ChapterView: View {
    let chapter: Chapter
    @State private var index = 0
    @Environment(\.dismiss) private var dismiss

    private var panel: StoryPanel { chapter.panels[index] }
    private var isLast: Bool { index == chapter.panels.count - 1 }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Full-bleed art (scene art fills the screen; the square guide bust
            // is centered over a themed backdrop so Hermes' head isn't cropped).
            Group {
                if let guide = panel.guide {
                    GuidePanel(base: guide)
                } else {
                    PanelImageView(imageName: panel.image)
                }
            }
            .id(index)
            .transition(.opacity)
            .ignoresSafeArea()

            // Floating UI: a slim top bar and the narration overlay at the bottom.
            VStack(spacing: 0) {
                topBar
                Spacer(minLength: 0)
                narrationOverlay
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .contentShape(Rectangle())
        .onTapGesture { if !isLast { advance() } }
        .statusBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .lockOrientation(.landscape)
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }
            ProgressView(value: Double(index + 1), total: Double(chapter.panels.count))
                .tint(.white)
                .frame(maxWidth: 260)
            Spacer(minLength: 0)
        }
    }

    private var narrationOverlay: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let speaker = panel.speaker {
                HStack(spacing: 8) {
                    HermesBadge()
                    Text(speaker)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.purple)
                }
            }
            Text(panel.text)
                .font(.title3)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            if isLast {
                NavigationLink {
                    TriviaView(category: chapter.quizCategory)
                } label: {
                    Label("Take the Quiz", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
            } else {
                HStack(spacing: 4) {
                    Spacer()
                    Text("Tap to continue")
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 18).fill(Color.black.opacity(0.35)))
        }
        .frame(maxWidth: 680)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func advance() {
        guard index < chapter.panels.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.35)) { index += 1 }
    }
}

/// The square guide bust (Hermes), centered and fully visible over a themed
/// backdrop so the landscape frame never crops his head.
private struct GuidePanel: View {
    let base: String

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.05, green: 0.13, blue: 0.16),
                                    Color(red: 0.08, green: 0.06, blue: 0.18)],
                           startPoint: .top, endPoint: .bottom)
            GuideSpeaker(base: base)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxHeight: .infinity)
        }
    }
}

/// The illustration for a panel, with a slow zoom/pan (Ken Burns). Shows a
/// branded placeholder until the named asset exists in the bundle.
private struct PanelImageView: View {
    let imageName: String
    @State private var animate = false

    var body: some View {
        // Color.clear sets the bounds; the image fills as a clipped overlay so its
        // scaledToFill size never widens the layout past the screen.
        Color.clear
            .overlay {
                imageOrPlaceholder
                    // Always start zoomed past 1.0 so the pan never reveals an edge.
                    .scaleEffect(animate ? 1.18 : 1.08)
                    .offset(x: animate ? -12 : 12, y: animate ? -8 : 8)
            }
            .clipped()
            .onAppear {
                animate = false
                withAnimation(.easeInOut(duration: 10)) { animate = true }
            }
    }

    @ViewBuilder
    private var imageOrPlaceholder: some View {
        if let uiImage = UIImage(named: imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            PlaceholderArt(label: imageName)
        }
    }
}

/// A simple coded stand-in for the guide. Swap for a Rive/illustrated Hermes later.
private struct HermesBadge: View {
    var body: some View {
        Image(systemName: "paperplane.fill")
            .font(.footnote.weight(.bold))
            .foregroundStyle(.white)
            .padding(7)
            .background(
                LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: Circle()
            )
    }
}

/// Branded placeholder shown until the real illustration is dropped in.
private struct PlaceholderArt: View {
    let label: String

    var body: some View {
        ZStack {
            LinearGradient(colors: [.indigo, .purple],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(spacing: 12) {
                Image(systemName: "photo.artframe")
                    .font(.system(size: 52))
                    .foregroundStyle(.white.opacity(0.85))
                Text(label)
                    .font(.callout.monospaced())
                    .foregroundStyle(.white.opacity(0.85))
                Text("art coming soon")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChapterView(chapter: ChapterLibrary.all[0])
    }
}
