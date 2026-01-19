import Foundation

struct StrategicTopic: Codable, Hashable, Identifiable {
    let sourceTitle: String
    let sourceLink: String
    let topicName: String
    let firstPrinciples: String
    let businessOpportunity: String
    let futureRoadmap: String

    var id: String { sourceLink.isEmpty ? sourceTitle : sourceLink }
}

