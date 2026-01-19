import Foundation

enum SignalType: String, Codable, CaseIterable, Identifiable {
    case emerging
    case dying
    case warning

    var id: String { rawValue }
}

struct Signal: Codable, Identifiable, Hashable {
    let signalId: String
    let date: Date
    let industry: String
    let signalType: SignalType
    let summary: String
    let evidence: String?
    let impact: String?
    let confidenceScore: Double?

    var id: String { signalId }
}

