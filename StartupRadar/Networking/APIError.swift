import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case httpError(statusCode: Int, body: String?)
    case decodingError(String)
    case transportError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .unauthorized:
            return "未授权（请重新登录）"
        case .httpError(let statusCode, let body):
            if let body, !body.isEmpty {
                return "请求失败（\(statusCode)）：\(body)"
            }
            return "请求失败（\(statusCode)）"
        case .decodingError(let msg):
            return "解析失败：\(msg)"
        case .transportError(let msg):
            return "网络错误：\(msg)"
        }
    }
}

