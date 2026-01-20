import Foundation

struct DailyOpportunity: Identifiable, Decodable, Hashable {
    let id: UUID

    /// yyyy-MM-dd（UTC），与 `Date.yyyyMMddUTCString()` 对齐
    let day: String?

    /// 可选：机会/风险/洞察等（后端可扩展）
    let kind: String?

    let title: String?
    let summary: String?

    let sourceTitle: String?
    let sourceUrl: String?

    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case day
        case kind
        case title
        case summary
        case sourceTitle = "source_title"
        case sourceUrl = "source_url"
        case createdAt = "created_at"
    }
}

