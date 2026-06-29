import SwiftUI

/// An animated "talking" guide built by swapping a few still frames
/// (e.g. `hermes-idle` / `hermes-talk` / `hermes-blink`). It talk-loops while
/// on screen with an occasional blink. Falls back to a branded placeholder
/// until the real frames are added — same pattern as the panel art.
struct GuideSpeaker: View {
    /// Frame asset base name, e.g. "hermes".
    let base: String

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.15)) { context in
            let tick = Int(context.date.timeIntervalSinceReferenceDate / 0.15)
            content(for: frameSuffix(tick: tick))
        }
    }

    /// Alternate idle/talk each tick (~5 swaps/sec) with a quick blink now and then.
    private func frameSuffix(tick: Int) -> String {
        if tick % 20 == 0 { return "blink" }
        return tick.isMultiple(of: 2) ? "talk" : "idle"
    }

    @ViewBuilder
    private func content(for suffix: String) -> some View {
        if let image = UIImage(named: "\(base)-\(suffix)") ?? UIImage(named: "\(base)-idle") {
            // Color.clear sets the bounds; the image fills as a clipped overlay so
            // its scaledToFill size never widens the layout past the screen.
            Color.clear
                .overlay { Image(uiImage: image).resizable().scaledToFill() }
                .clipped()
        } else {
            GuidePlaceholder(base: base)
        }
    }
}

/// Branded stand-in shown until the guide's frames are dropped in.
private struct GuidePlaceholder: View {
    let base: String

    var body: some View {
        ZStack {
            LinearGradient(colors: [.teal, .indigo], startPoint: .top, endPoint: .bottom)
            VStack(spacing: 14) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.white)
                Text("\(base)-idle / -talk / -blink")
                    .font(.callout.monospaced())
                    .foregroundStyle(.white.opacity(0.85))
                Text("guide frames coming soon")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}

#Preview {
    GuideSpeaker(base: "hermes")
}
