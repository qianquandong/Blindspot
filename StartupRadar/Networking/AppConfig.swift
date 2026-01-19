import Foundation

enum AppConfig {
    /// 通过 Info.plist 的 `API_BASE_URL` 读取；若未配置则使用占位值。
    static var apiBaseURL: URL {
        if let value = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           let url = URL(string: value),
           url.scheme != nil {
            return url
        }
        // TODO: 请在 Xcode 的 Build Settings/Info.plist 里补上 API_BASE_URL
        return URL(string: "https://api.example.com")!
    }

    /// 无后端时走本地 Demo 数据：默认当 `API_BASE_URL` 仍是占位域名时启用
    static var isMockMode: Bool {
        apiBaseURL.host == "api.example.com"
    }
}

