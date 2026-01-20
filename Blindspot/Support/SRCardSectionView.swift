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
        title: "First principles",
        text: "More spacious paragraph spacing makes this feel like a card, not a cramped list.",
        tint: .purple
    )
    .padding()
}

