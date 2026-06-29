import SwiftUI

/// Plays one illustrated chapter: image (with a slow Ken Burns drift) + narration,
/// tap-to-advance with a crossfade, ending in a button to the matching quiz.
struct ChapterView: View {
    let chapter: Chapter
    @State private var index = 0

    private var panel: StoryPanel { chapter.panels[index] }
    private var isLast: Bool { index == chapter.panels.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            ProgressView(value: Double(index + 1), total: Double(chapter.panels.count))
                .tint(.accentColor)
                .padding(.horizontal)
                .padding(.top, 8)

            // Image + narration crossfade together as the panel changes.
            VStack(spacing: 0) {
                PanelImageView(imageName: panel.image)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                NarrationCard(speaker: panel.speaker, text: panel.text)
            }
            .id(index)
            .transition(.opacity)
            .contentShape(Rectangle())
            .onTapGesture { if !isLast { advance() } }

            controls
                .padding()
        }
        .navigationTitle(chapter.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var controls: some View {
        if isLast {
            NavigationLink {
                TriviaView(category: chapter.quizCategory)
            } label: {
                Label("Take the Quiz", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
        } else {
            Button { advance() } label: {
                HStack {
                    Text("Continue").font(.headline)
                    Image(systemName: "chevron.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func advance() {
        guard index < chapter.panels.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.35)) { index += 1 }
    }
}

/// The illustration for a panel, with a slow zoom/pan (Ken Burns). Shows a
/// branded placeholder until the named asset exists in the bundle.
private struct PanelImageView: View {
    let imageName: String
    @State private var animate = false

    var body: some View {
        Group {
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                PlaceholderArt(label: imageName)
            }
        }
        // Always start zoomed slightly past 1.0 so the pan never reveals an edge.
        .scaleEffect(animate ? 1.18 : 1.08)
        .offset(x: animate ? -12 : 12, y: animate ? -8 : 8)
        .onAppear {
            animate = false
            withAnimation(.easeInOut(duration: 10)) { animate = true }
        }
    }
}

/// Narration text with an optional speaker badge for the guide.
private struct NarrationCard: View {
    let speaker: String?
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let speaker {
                HStack(spacing: 8) {
                    HermesBadge()
                    Text(speaker)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.purple)
                }
            }
            Text(text)
                .font(.title3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
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
