import Foundation

extension Bundle {
    /// Loads and decodes a JSON file bundled with the app.
    ///
    /// Crashes with a clear message if the file is missing or malformed — these
    /// are bugs we want to catch immediately during development, not ship.
    func decode<T: Decodable>(_ type: T.Type, from filename: String) -> T {
        guard let url = self.url(forResource: filename, withExtension: nil) else {
            fatalError("Couldn't find \(filename) in the app bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Couldn't load \(filename) from the app bundle.")
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            fatalError("Couldn't decode \(filename): \(error)")
        }
    }
}
