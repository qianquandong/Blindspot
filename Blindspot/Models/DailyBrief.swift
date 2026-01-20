import Foundation

struct DailyBrief: Codable, Hashable {
    let date: Date
    let opportunities: [Signal]
    let risks: [Signal]
    let dailyConclusion: String
    let suggestedActions: [String]?
    let updatedAt: Date?
}

