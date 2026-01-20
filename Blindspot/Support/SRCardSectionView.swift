import SwiftUI

struct SRCardSectionView: View {
    let icon: String
    let title: String
    let text: String
    var tint: Color = .purple

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SRBadgeView(icon: icon, title: title, tint: tint)

            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(6)
                .textSelection(.enabled)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)
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

