import Foundation

/// Loads the "Learn" chapters once from the bundle. Mirrors `QuestionBank`.
enum ChapterLibrary {
    static let all: [Chapter] = Bundle.main.decode([Chapter].self, from: "chapters.json")
}
