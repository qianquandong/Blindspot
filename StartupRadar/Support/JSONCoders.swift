import Foundation

enum JSONCoders {
    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)

            // 1) ISO8601（常见：2026-01-18T12:34:56Z）
            if let date = ISO8601DateFormatter().date(from: str) {
                return date
            }

            // 2) 仅日期（PRD：按 date 拉取，可能是 YYYY-MM-DD）
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone(secondsFromGMT: 0)
            df.dateFormat = "yyyy-MM-dd"
            if let date = df.date(from: str) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "无法解析日期：\(str)")
        }
        return decoder
    }

    static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

