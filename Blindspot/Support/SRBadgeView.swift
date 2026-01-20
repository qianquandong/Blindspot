import SwiftUI

struct SRBadgeView: View {
    let icon: String
    let title: String
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Text(icon)
            Text(title)
                .fontWeight(.semibold)
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(tint.opacity(0.95))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tint.opacity(0.14))
        .clipShape(Capsule(style: .continuous))
        .overlay(
            Capsule(style: .continuous)
                .stroke(tint.opacity(0.25), lineWidth: 0.5)
        )
        .accessibilityLabel(title)
    }
}

#Preview {
    VStack(spacing: 12) {
        SRBadgeView(icon: "🧬", title: "第一性原理", tint: .purple)
        SRBadgeView(icon: "💰", title: "商业机会", tint: .green)
        SRBadgeView(icon: "🗺️", title: "未来路线", tint: .blue)
    }
    .padding()
}

