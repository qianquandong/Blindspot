import Foundation

enum DemoReportStore {
    private static let demoJSONSourceHint = "Blindspot/Demo/NBCReportDemoData.swift (embedded string)"

    static func loadNBCReport() -> DailyStrategicReport {
        guard let data = NBCReportDemoData.json.data(using: .utf8) else {
            return fallbackReport(reason: "demo json to utf8 failed")
        }
        do {
            // 1) 先用 JSONSerialization 做语法级校验，失败则给出更直观的“第几行/第几列”
            //    这一步专门用来定位 dataCorrupted（非法 JSON、未转义换行、BOM、编码问题等）
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
#if DEBUG
                print("DemoReportStore JSONSerialization failed:", error)
                print("DemoReportStore JSON source:", demoJSONSourceHint)
                print("DemoReportStore JSON prefix(500):", String(NBCReportDemoData.json.prefix(500)))
#endif
                return fallbackReport(reason: "dataCorrupted: invalid json (JSONSerialization) from \(demoJSONSourceHint): \(error)")
            }

            let decoder = JSONDecoder()
            // 与我们生成 Demo JSON 的 key 风格兼容（同时也对未来 snake_case 后端留后门）
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(DailyStrategicReport.self, from: data)
        } catch {
#if DEBUG
            print("DemoReportStore.loadNBCReport decode error:", prettyDecodingError(error))
            print("DemoReportStore JSON source:", demoJSONSourceHint)
            print("DemoReportStore JSON prefix(500):", String(NBCReportDemoData.json.prefix(500)))
#endif
            return fallbackReport(reason: "decode failed: \(String(describing: error))")
        }
    }

    static func nbcEmailHTML() -> String {
        NBCReportDemoData.emailHTML
    }

    private static func fallbackReport(reason: String) -> DailyStrategicReport {
        let approxSize = NBCReportDemoData.json.utf8.count
        return DailyStrategicReport(
            date: "1970-01-01",
            generatedAt: "1970-01-01T00:00:00Z",
            location: "Local Demo",
            source: .init(name: "NBC Demo (fallback)", link: "https://feeds.nbcnews.com/nbcnews/public/news"),
            topics: [
                StrategicTopic(
                    sourceTitle: "Demo 数据不可用",
                    sourceLink: "https://feeds.nbcnews.com/nbcnews/public/news",
                    topicName: "Demo 数据不可用（\(reason)）",
                    firstPrinciples: "已检测到 Demo JSON 解析失败。当前内嵌 JSON 大小约 \(approxSize) bytes。请把此页的错误原因（括号内）发我，我会按具体 DecodingError 精确修复。",
                    businessOpportunity: "当前为兜底提示，用于避免 Today 页面空白。",
                    futureRoadmap: "修复 Demo 数据后，此条将被真实话题列表替换。"
                )
            ]
        )
    }

    private static func prettyDecodingError(_ error: Error) -> String {
        guard let err = error as? DecodingError else { return String(describing: error) }

        func path(_ codingPath: [CodingKey]) -> String {
            if codingPath.isEmpty { return "(root)" }
            return codingPath.map { $0.intValue.map(String.init) ?? $0.stringValue }.joined(separator: ".")
        }

        switch err {
        case .dataCorrupted(let ctx):
            return "dataCorrupted at \(path(ctx.codingPath)): \(ctx.debugDescription)"
        case .keyNotFound(let key, let ctx):
            return "keyNotFound(\(key.stringValue)) at \(path(ctx.codingPath)): \(ctx.debugDescription)"
        case .typeMismatch(let type, let ctx):
            return "typeMismatch(\(type)) at \(path(ctx.codingPath)): \(ctx.debugDescription)"
        case .valueNotFound(let type, let ctx):
            return "valueNotFound(\(type)) at \(path(ctx.codingPath)): \(ctx.debugDescription)"
        @unknown default:
            return String(describing: err)
        }
    }
}

