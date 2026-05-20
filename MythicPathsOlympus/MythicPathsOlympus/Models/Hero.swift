import Foundation

struct Hero: Identifiable, Codable {
    let id: String
    let name: String
    let subtitle: String
    let description: String
    var portraitOffset: CGFloat = 0

    var portraitName: String { "\(id)-portrait" }
}
