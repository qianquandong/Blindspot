import Foundation

struct EliteBrief: Codable, Hashable {
    let mainDirection: String
    let alternatives: [String]
    let whyYou: String
    let nextSteps: [String]
    let riskNotes: String?
    let updatedAt: Date?
}

