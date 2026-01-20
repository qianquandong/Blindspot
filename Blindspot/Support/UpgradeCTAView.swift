import SwiftUI

struct UpgradeCTAView: View {
    let title: String
    let message: String
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        let t = { (en: String, zh: String) in SRL10n.t(en: en, zhHans: zh, lang: appLanguage) }

        return VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text(message)
                .foregroundStyle(.secondary)
                .font(.subheadline)
            Text(t("Go to Profile to upgrade", "去 Profile 升级订阅"))
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
    UpgradeCTAView(title: "Unlock Pro", message: "Upgrade to see the full daily conclusion and suggested actions.")
        .padding()
}

