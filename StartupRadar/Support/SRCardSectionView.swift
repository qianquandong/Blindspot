import SwiftUI

struct SRCardSectionView: View {
    let icon: String
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(icon)
                    .font(.title3)
                Text(title)
                    .font(.headline)
            }

            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(4)
                .textSelection(.enabled)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 0.5)
        )
    }
}

#Preview {
    SRCardSectionView(
        icon: "🧬",
        title: "第一性原理",
        text: "这里是更舒展的段落排版与行距，阅读体验更像卡片，而不是挤在 List 里。"
    )
    .padding()
}

