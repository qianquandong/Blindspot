import Foundation

struct SignalsPage: Codable {
    let items: [Signal]
    let nextCursor: String?
    let updatedAt: Date?
}

