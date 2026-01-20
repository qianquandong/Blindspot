import Foundation

struct StrategicTopic: Codable, Hashable, Identifiable {
    let sourceTitle: String
    let sourceLink: String
    let topicName: String
    let firstPrinciples: String
    let businessOpportunity: String
    let futureRoadmap: String

    /// 用于 SwiftUI List/ForEach 的稳定唯一 ID。
    /// 注意：sourceLink 在 Demo 数据里会对多条 topic 相同（同一个 RSS 源），所以必须叠加 topicName。
    var id: String {
        let src = sourceLink.isEmpty ? sourceTitle : sourceLink
        return "\(src)|\(topicName)"
    }
}

