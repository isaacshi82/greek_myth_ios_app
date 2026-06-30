import SwiftUI

/// Plays one illustrated chapter in landscape. Each panel picks its layout from
/// the art's shape: wide art goes full-bleed with the narration over a bottom
/// scrim; square art (and the Hermes guide) uses an artistic left/right split so
/// text never covers the picture. The narration fades in a beat after the image
/// so the full picture is visible first, and fades out before the next panel.
struct ChapterView: View {
    let chapter: Chapter
    @State private var index = 0
    @State private var revealText = false
    @State private var revealToken = 0
    @Environment(\.dismiss) private var dismiss

    /// How long the picture is shown alone before the narration fades in.
    private let revealDelay = 0.8
    /// Dark panel color behind split-layout text (also used to blend the seam).
    private let splitSide = Color(red: 0.07, green: 0.10, blue: 0.16)

    private var panel: StoryPanel { chapter.panels[index] }
    private var isLast: Bool { index == chapter.panels.count - 1 }

    /// Square art (and the guide) reads better as a side-by-side split; wide art
    /// fills the screen. Decided from the asset's real pixel aspect ratio.
    private var isSplit: Bool {
        if panel.guide != nil { return true }
        guard let img = UIImage(named: panel.image) else { return false }
        return img.size.width / img.size.height < 1.3
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()

            if isSplit { splitLayout } else { fullBleedLayout }

            topBar
                .padding(.horizontal, 20)
                .padding(.top, 10)
        }
        .contentShape(Rectangle())
        .onTapGesture { if !isLast { advance() } }
        .onChange(of: index) { _, _ in
            if isLast { ProgressStore.shared.completeChapter(chapter.id) }
        }
        .onAppear { scheduleReveal() }
        .statusBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .lockOrientation(.landscape)
    }

    // MARK: - Layouts

    /// Square art / guide: image fills one half, narration on a dark panel beside it.
    private var splitLayout: some View {
        HStack(spacing: 0) {
            narration(split: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(splitSide)
                .opacity(revealText ? 1 : 0)

            artView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .id(index)
                .transition(.opacity)
                // Melt the image's inner edge into the text panel for a soft seam.
                .overlay(alignment: .leading) {
                    LinearGradient(colors: [splitSide, .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: 80)
                        .frame(maxHeight: .infinity)
                        .allowsHitTesting(false)
                }
        }
        .ignoresSafeArea()
    }

    /// Wide art: fills the screen; narration sits at the bottom over a gradient scrim.
    private var fullBleedLayout: some View {
        ZStack(alignment: .bottom) {
            artView
                .id(index)
                .transition(.opacity)
                .ignoresSafeArea()

            narration(split: false)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(colors: [.clear, .black.opacity(0.5), .black.opacity(0.85)],
                                   startPoint: .top, endPoint: .bottom)
                )
                .opacity(revealText ? 1 : 0)
        }
        .ignoresSafeArea()
    }

    // MARK: - Pieces

    @ViewBuilder
    private var artView: some View {
        if let guide = panel.guide {
            GuideSpeaker(base: guide)
        } else {
            PanelImageView(imageName: panel.image)
        }
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

    /// The narration text + speaker + footer. `split` tunes spacing/size for the
    /// side panel vs. the bottom caption.
    private func narration(split: Bool) -> some View {
        VStack(alignment: .leading, spacing: split ? 16 : 12) {
            if let speaker = panel.speaker {
                HStack(spacing: 8) {
                    HermesBadge()
                    Text(speaker)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.purple)
                }
            }
            Text(panel.text)
                .font(split ? .title2 : .title3)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            footer
        }
        .padding(.horizontal, split ? 34 : 26)
        .padding(.vertical, split ? 34 : 22)
    }

    @ViewBuilder
    private var footer: some View {
        if isLast {
            NavigationLink {
                TriviaView(category: chapter.quizCategory)
            } label: {
                Label("Take the Quiz", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
            .padding(.top, 4)
        } else {
            HStack(spacing: 4) {
                Text("Tap to continue")
                Image(systemName: "chevron.right")
            }
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.75))
        }
    }

    // MARK: - Timed reveal

    private func advance() {
        guard index < chapter.panels.count - 1 else { return }
        withAnimation(.easeOut(duration: 0.25)) { revealText = false }
        withAnimation(.easeInOut(duration: 0.4)) { index += 1 }
        scheduleReveal()
    }

    /// Reveal the narration a beat after the image settles. A token guards against
    /// fast taps so an old timer can't reveal text on a newer panel.
    private func scheduleReveal() {
        revealToken += 1
        let token = revealToken
        DispatchQueue.main.asyncAfter(deadline: .now() + revealDelay) {
            if token == revealToken {
                withAnimation(.easeInOut(duration: 0.45)) { revealText = true }
            }
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
