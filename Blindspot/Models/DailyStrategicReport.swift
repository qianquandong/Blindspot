import Foundation

struct DailyStrategicReport: Codable, Hashable {
    struct Source: Codable, Hashable {
        let name: String
        let link: String
    }

    let date: String
    let generatedAt: String
    let location: String
    let source: Source
    let topics: [StrategicTopic]
}

