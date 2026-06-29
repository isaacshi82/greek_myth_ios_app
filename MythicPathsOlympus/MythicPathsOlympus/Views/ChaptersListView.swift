import SwiftUI

/// Lists the available "Learn" chapters. Tapping one opens the chapter player.
struct ChaptersListView: View {
    var body: some View {
        List {
            ForEach(ChapterLibrary.all) { chapter in
                NavigationLink {
                    ChapterView(chapter: chapter)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(chapter.unit.uppercased())
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(chapter.title)
                            .font(.headline)
                        Text("\(chapter.panels.count) parts · ends with a quiz")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Learn the Myths")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ChaptersListView()
    }
}
