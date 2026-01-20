import SwiftUI

struct UpgradeCTAView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text(message)
                .foregroundStyle(.secondary)
                .font(.subheadline)
            Text("去 Profile 升级订阅")
                .font(.subheadline.weight(.semibold))
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    UpgradeCTAView(title: "解锁 Pro", message: "升级后可查看完整今日结论与行动建议")
        .padding()
}

