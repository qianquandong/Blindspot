import Foundation

enum SRL10n {
    /// 最小可用的“应用内语言切换”本地化：
    /// - 默认英文（en）
    /// - 可选简体中文（zh-Hans）
    /// - 不依赖 Xcode 的 Localizable.strings（避免改 pbxproj）
    static func t(en: String, zhHans: String, lang: AppLanguage) -> String {
        switch lang {
        case .en:
            return en
        case .zhHans:
            return zhHans
        }
    }
}

