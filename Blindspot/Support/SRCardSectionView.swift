import SwiftUI

struct SRCardSectionView: View {
    let icon: String
    let title: String
    let text: String
    var tint: Color = .purple

    var body: some View {
        SRCard(background: tint.opacity(0.12)) {
            VStack(alignment: .leading, spacing: 12) {
                SRBadgeView(icon: icon, title: title, tint: tint)

                Text(text)
                    .font(.body)
                    .foregroundStyle(SRTheme.body)
                    .lineSpacing(7)
                    .textSelection(.enabled)
            }
        }
    }
}

#Preview {
    SRCardSectionView(
        icon: "🧬",
        title: "第一性原理",
        text: "这里是更舒展的段落排版与行距，阅读体验更像卡片，而不是挤在 List 里。",
        tint: .purple
    )
    .padding()
}

