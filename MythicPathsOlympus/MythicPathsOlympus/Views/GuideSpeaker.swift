import SwiftUI

/// An animated "talking" guide built by swapping a few still frames
/// (e.g. `hermes-idle` / `hermes-talk` / `hermes-blink`). It talk-loops while
/// on screen with an occasional blink. Falls back to a branded placeholder
/// until the real frames are added — same pattern as the panel art.
struct GuideSpeaker: View {
    /// Frame asset base name, e.g. "hermes".
    let base: String

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            content(for: frameSuffix(at: context.date.timeIntervalSinceReferenceDate))
        }
    }

    /// A short talk burst (~1s of mouth flaps) at the start of each 5s window,
    /// idle the rest of the time, with a quick blink every 10s.
    private func frameSuffix(at t: TimeInterval) -> String {
        if t.truncatingRemainder(dividingBy: 10) < 0.2 { return "blink" }
        let inWindow = t.truncatingRemainder(dividingBy: 5)
        if inWindow < 1.0 {
            return Int(inWindow / 0.2).isMultiple(of: 2) ? "talk" : "idle"
        }
        return "idle"
    }

    @ViewBuilder
    private func content(for suffix: String) -> some View {
        if let image = UIImage(named: "\(base)-\(suffix)") ?? UIImage(named: "\(base)-idle") {
            // Color.clear sets the bounds; the image fills as a clipped overlay so
            // its scaledToFill size never widens the layout past the screen.
            // Scaling slightly from the top crops off the bottom edge, where the
            // frames differ — which would otherwise flicker when they swap.
            Color.clear
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(1.15, anchor: .top)
                }
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
