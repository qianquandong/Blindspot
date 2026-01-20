import SwiftUI

/// Blindspot 轻量设计系统（马卡龙风格）：
/// - 白底大留白
/// - 高明度、低饱和度（Pastel）
/// - 大圆角 + 轻阴影
enum SRTheme {
    // MARK: - Colors

    static let background = Color.white
    static let surface = Color.white
    static let title = Color.black
    static let body = Color.black.opacity(0.78)
    static let secondaryText = Color.black.opacity(0.55)

    /// 主视觉浅紫（参考图风格）
    static let pastelLavender = Color(hex: 0xCFCBFF)
    /// 辅色薄荷绿
    static let pastelMint = Color(hex: 0xC9F4D8)
    /// 可选淡蓝（用于信息/中性卡片）
    static let pastelBlue = Color(hex: 0xCFEAFF)

    static let cardBorder = Color.black.opacity(0.07)

    // MARK: - Layout

    enum Spacing {
        static let xs: CGFloat = 6
        static let s: CGFloat = 10
        static let m: CGFloat = 14
        static let l: CGFloat = 18
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Radius {
        /// 大圆角（贴近参考图）
        static let card: CGFloat = 26
        static let cardInner: CGFloat = 18
    }

    enum Shadow {
        static let color = Color.black.opacity(0.10)
        static let radius: CGFloat = 18
        static let y: CGFloat = 10
    }

    // MARK: - Typography

    static func heroTitleFont() -> Font {
        .system(size: 40, weight: .black, design: .default)
    }

    static func sectionTitleFont() -> Font {
        .system(size: 22, weight: .bold, design: .default)
    }

    static func cardTitleFont() -> Font {
        .system(.headline, design: .default).weight(.bold)
    }
}

// MARK: - Color helpers

private extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

