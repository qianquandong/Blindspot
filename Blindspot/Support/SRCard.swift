import SwiftUI

/// 统一卡片容器（大圆角 + 轻阴影 + 细描边）
struct SRCard<Content: View>: View {
    var background: Color = SRTheme.surface
    var cornerRadius: CGFloat = SRTheme.Radius.card
    var padding: CGFloat = 18
    var showsBorder: Bool = true

    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                if showsBorder {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(SRTheme.cardBorder, lineWidth: 0.8)
                }
            }
            .shadow(color: SRTheme.Shadow.color, radius: SRTheme.Shadow.radius, x: 0, y: SRTheme.Shadow.y)
    }
}

/// Hero 卡片：更大的内边距，适合“今日结论”等主视觉块
struct SRHeroCard<Content: View>: View {
    var background: Color = SRTheme.pastelLavender
    var cornerRadius: CGFloat = SRTheme.Radius.card
    var padding: CGFloat = 22

    @ViewBuilder var content: Content

    var body: some View {
        SRCard(background: background, cornerRadius: cornerRadius, padding: padding, showsBorder: false) {
            content
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        SRHeroCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("今日结论")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SRTheme.secondaryText)
                Text("用更少的噪音，更快做出判断。")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(SRTheme.title)
            }
        }

        SRCard(background: SRTheme.pastelMint.opacity(0.55)) {
            Text("这是一个普通卡片。")
                .foregroundStyle(SRTheme.body)
        }
    }
    .padding()
    .background(SRTheme.background)
}

