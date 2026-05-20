import Foundation

struct Choice: Identifiable, Codable {
    let id: String
    let text: String
    let nextNodeId: String
}

struct StoryNode: Identifiable, Codable {
    let id: String
    let text: String
    let choices: [Choice]
    let isEnding: Bool
}

struct HeroStory: Codable {
    let heroId: String
    let nodes: [StoryNode]
    let startNodeId: String
}
