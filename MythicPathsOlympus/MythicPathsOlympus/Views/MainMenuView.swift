import SwiftUI

struct MainMenuView: View {
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

#Preview {
    MainMenuView()
}
