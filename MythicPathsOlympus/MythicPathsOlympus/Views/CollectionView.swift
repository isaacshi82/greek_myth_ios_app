import SwiftUI

/// The player's Pantheon: a grid of mythological figures earned through play.
/// Unlocked cards are tappable for lore; locked cards show how to earn them.
struct CollectionView: View {
    @ObservedObject private var progress = ProgressStore.shared
    @State private var selected: Collectible?

    private let columns = [GridItem(.flexible(), spacing: 16),
                           GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ScrollView {
            header
                .padding(.horizontal)
                .padding(.top, 8)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Pantheon.all) { figure in
                    let unlocked = progress.isUnlocked(figure)
                    CollectibleCard(figure: figure, unlocked: unlocked, hint: progress.hint(for: figure))
                        .onTapGesture { if unlocked { selected = figure } }
                }
            }
            .padding()
        }
        .navigationTitle("Your Pantheon")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selected) { CollectibleDetailView(figure: $0) }
    }

    private var header: some View {
        let collected = progress.collectedCount
        let total = Pantheon.all.count
        return VStack(alignment: .leading, spacing: 10) {
            Text("\(collected) of \(total) collected")
                .font(.title3.weight(.bold))
            ProgressView(value: Double(collected), total: Double(total))
                .tint(.yellow)
            Text("Play trivia and read chapters to earn the gods, Titans, and heroes of myth.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// One figure in the grid. Unlocked: gradient + emoji/art + name. Locked: a
/// shadowed silhouette with the requirement to earn it.
private struct CollectibleCard: View {
    let figure: Collectible
    let unlocked: Bool
    let hint: (text: String, progress: Double?)

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if unlocked {
                    LinearGradient(colors: figure.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    artOrEmoji
                } else {
                    LinearGradient(colors: [Color(.systemGray4), Color(.systemGray6)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 130)
            .frame(maxWidth: .infinity)

            VStack(spacing: 4) {
                Text(unlocked ? figure.name : "???")
                    .font(.headline)
                    .foregroundStyle(unlocked ? .primary : .secondary)
                if unlocked {
                    Text(figure.epithet)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                } else {
                    Text(hint.text)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                    if let p = hint.progress {
                        ProgressView(value: min(max(p, 0), 1))
                            .tint(.yellow)
                            .padding(.top, 2)
                    }
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 86, alignment: .top)
            .background(Color(.secondarySystemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.08)))
    }

    @ViewBuilder
    private var artOrEmoji: some View {
        if UIImage(named: figure.imageName) != nil {
            Image(figure.imageName)
                .resizable()
                .scaledToFill()
        } else {
            Text(figure.emoji)
                .font(.system(size: 60))
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
        }
    }
}

/// Lore card shown when an unlocked figure is tapped.
private struct CollectibleDetailView: View {
    let figure: Collectible
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(colors: figure.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    if UIImage(named: figure.imageName) != nil {
                        Image(figure.imageName).resizable().scaledToFill()
                    } else {
                        Text(figure.emoji)
                            .font(.system(size: 96))
                            .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
                    }
                }
                .frame(height: 220)
                .clipped()

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(figure.name).font(.largeTitle.bold())
                            Text(figure.epithet).font(.title3).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(figure.domain)
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color(.secondarySystemBackground), in: Capsule())
                    }
                    Divider()
                    Text(figure.lore)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding()
        }
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    NavigationStack { CollectionView() }
}
