import Foundation

enum MockServer {
    static func responseData(
        path: String,
        method: String,
        queryItems: [URLQueryItem],
        body: Data?
    ) throws -> Data {
        // 统一去掉 baseURL，只看 path
        switch (method.uppercased(), path) {
        case ("GET", "/today"):
            // 无后端 Demo：Today 走本地预分析报告（不走 DailyBrief）
            let report = DemoReportStore.loadNBCReport()
            return try JSONCoders.encoder().encode(report)

        case ("GET", "/signals"):
            let limit = Int(queryItems.first(where: { $0.name == "limit" })?.value ?? "") ?? 50
            let cursor = Int(queryItems.first(where: { $0.name == "cursor" })?.value ?? "0") ?? 0
            let type = queryItems.first(where: { $0.name == "type" })?.value
            let industry = queryItems.first(where: { $0.name == "industry" })?.value

            let all = makeSignalsFromReport()
                .filter { s in
                    if let type, !type.isEmpty, s.signalType.rawValue != type { return false }
                    if let industry, !industry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        return s.industry.localizedCaseInsensitiveContains(industry)
                    }
                    return true
                }

            let start = max(0, min(cursor, all.count))
            let end = max(start, min(start + limit, all.count))
            let items = Array(all[start..<end])
            let nextCursor = end < all.count ? String(end) : nil
            let page = SignalsPage(items: items, nextCursor: nextCursor, updatedAt: Date())
            return try JSONCoders.encoder().encode(page)

        default:
            throw APIError.httpError(statusCode: 404, body: "Mock: endpoint not found \(method) \(path)")
        }
    }

    private static func makeSignalsFromReport() -> [Signal] {
        let report = DemoReportStore.loadNBCReport()
        return report.topics.enumerated().map { idx, t in
            let stype = classifySignalType(title: t.topicName)
            return Signal(
                signalId: "nbc-\(idx)",
                date: Date(),
                industry: "News",
                signalType: stype,
                summary: t.topicName,
                evidence: t.sourceLink,
                impact: t.firstPrinciples,
                confidenceScore: 0.6
            )
        }
    }

    private static func classifySignalType(title: String) -> SignalType {
        let lower = title.lowercased()
        let warningWords = ["tariff", "protest", "investigation", "fear", "killed", "unrest", "storm", "freezing", "danger", "doj", "ice"]
        let dyingWords = ["dying", "collapse", "bankrupt", "recession"]
        if dyingWords.contains(where: { lower.contains($0) }) { return .dying }
        if warningWords.contains(where: { lower.contains($0) }) { return .warning }
        return .emerging
    }
}

