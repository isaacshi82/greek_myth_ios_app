import SwiftUI

/// An animated "talking" guide built by swapping still frames
/// (`hermes-idle` / `-talk` / `-blink` / `-wink`). Talk burst every 5s, a blink
/// every 8.5s, and a playful wink every 13s — all off-cycle so it feels organic.
/// Falls back to a branded placeholder until the frames are added.
struct GuideSpeaker: View {
    /// Frame asset base name, e.g. "hermes".
    let base: String

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            GuideFrameImage(
                name: frameName(at: context.date.timeIntervalSinceReferenceDate),
                placeholderBase: base
            )
        }
    }

    /// Pick the frame for the current time, falling back to idle if a frame is missing.
    private func frameName(at t: TimeInterval) -> String {
        let suffix: String
        if t.truncatingRemainder(dividingBy: 8.5) < 0.2 {
            suffix = "blink"
        } else if t.truncatingRemainder(dividingBy: 13) < 0.35 {
            suffix = "wink"
        } else {
            let inWindow = t.truncatingRemainder(dividingBy: 5)
            suffix = inWindow < 1.0 ? (Int(inWindow / 0.2).isMultiple(of: 2) ? "talk" : "idle") : "idle"
        }
        let candidate = "\(base)-\(suffix)"
        return UIImage(named: candidate) != nil ? candidate : "\(base)-idle"
    }
}

/// Renders a single guide frame (or a placeholder if missing). Scales slightly
/// from the top so the frames' differing bottom edge is cropped away — which
/// would otherwise flicker when frames swap.
struct GuideFrameImage: View {
    let name: String
    var placeholderBase: String? = nil

    var body: some View {
        if let image = UIImage(named: name) {
            Color.clear
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(1.15, anchor: .top)
                }
                .clipped()
        } else {
            GuidePlaceholder(base: placeholderBase ?? name)
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
