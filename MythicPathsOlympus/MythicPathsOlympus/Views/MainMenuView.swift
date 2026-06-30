import SwiftUI

struct MainMenuView: View {
    /// Story mode is built but parked for now. Flip to `true` to show the hero cards again.
    let showStoryMode = false

    @ObservedObject private var progress = ProgressStore.shared

    let heroes: [Hero] = [
        Hero(id: "perseus", name: "Perseus", subtitle: "Slayer of Medusa", description: "Son of Zeus, destined to face the Gorgon."),
        Hero(id: "theseus", name: "Theseus", subtitle: "Hero of Athens", description: "The prince who entered the Labyrinth."),
        Hero(id: "odysseus", name: "Odysseus", subtitle: "The Wanderer", description: "The cleverest hero of the Trojan War.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    Text("Mythic Paths")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 48)
                    Text("Olympus")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 32)

                    // Learn mode — illustrated, guided myth chapters.
                    NavigationLink(destination: ChaptersListView()) {
                        LearnMenuCard()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)

                    // Trivia mode — the first playable feature.
                    NavigationLink(destination: TriviaSetupView()) {
                        TriviaMenuCard()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)

                    // Collection — the gods/heroes you've earned through play.
                    NavigationLink(destination: CollectionView()) {
                        CollectionMenuCard(collected: progress.collectedCount, total: Pantheon.all.count)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)

                    if showStoryMode {
                        Text("Choose your hero")
                            .font(.headline)
                            .padding(.bottom, 16)

                        ForEach(heroes) { hero in
                            NavigationLink(destination: Text("Story for \(hero.name) — coming soon")) {
                                HeroCard(hero: hero)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                        }
                    }
                }
            }
        }
    }
}

struct HeroCard: View {
    let hero: Hero

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(hero.portraitName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .offset(y: hero.portraitOffset)
                .frame(height: 220, alignment: .top)
                .clipped()

            LinearGradient(
                colors: [.clear, .black.opacity(0.75)],
                startPoint: .center,
                endPoint: .bottom
            )

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(hero.name)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.white)
                    Text(hero.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.title3)
            }
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct LearnMenuCard: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "book.pages.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 4) {
                Text("Learn the Myths")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                Text("Guided stories from the world of the gods")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.7))
                .font(.title3)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.teal, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}

struct CollectionMenuCard: View {
    let collected: Int
    let total: Int

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 4) {
                Text("Your Pantheon")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                Text("\(collected) of \(total) figures collected")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.7))
                .font(.title3)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.orange, .yellow],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}

struct TriviaMenuCard: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 4) {
                Text("Trivia Challenge")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                Text("Test your knowledge of the myths")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.7))
                .font(.title3)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.indigo, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}

#Preview {
    MainMenuView()
}
