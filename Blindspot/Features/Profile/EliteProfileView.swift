import SwiftUI

struct EliteProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appLanguage) private var appLanguage

    @State private var industryExperience: String
    @State private var skillTagsText: String
    @State private var weeklyHours: Int
    @State private var budgetUSD: Int
    @State private var riskPreference: String

    init(existing: EliteProfile?) {
        _industryExperience = State(initialValue: existing?.industryExperience ?? "")
        _skillTagsText = State(initialValue: (existing?.skillTags ?? []).joined(separator: ", "))
        _weeklyHours = State(initialValue: existing?.weeklyHours ?? 10)
        _budgetUSD = State(initialValue: existing?.budgetUSD ?? 0)
        // migrate legacy zh values to new codes
        let legacy = existing?.riskPreference ?? "medium"
        let normalized: String
        switch legacy {
        case "保守":
            normalized = "conservative"
        case "中等":
            normalized = "medium"
        case "激进":
            normalized = "aggressive"
        default:
            normalized = legacy
        }
        _riskPreference = State(initialValue: normalized)
    }

    var body: some View {
        let t = { (en: String, zh: String) in SRL10n.t(en: en, zhHans: zh, lang: appLanguage) }

        return Form {
            Section(t("Industry experience", "行业经验")) {
                TextField(t("e.g. SaaS / E-commerce / Education", "例如：SaaS / 电商 / 教育"), text: $industryExperience)
            }

            Section(t("Skills", "技能标签")) {
                TextField(t("Comma-separated, e.g. Coding, Automation, Ops", "用逗号分隔，例如：编程, 自动化, 运营"), text: $skillTagsText)
                    .textInputAutocapitalization(.never)
            }

            Section(t("Time available (per week)", "可投入时间（每周）")) {
                Stepper(String(format: t("%d hours", "%d 小时"), weeklyHours), value: $weeklyHours, in: 0...80)
            }

            Section(t("Budget (USD)", "预算（USD）")) {
                Stepper("\(budgetUSD)", value: $budgetUSD, in: 0...1_000_000, step: 50)
            }

            Section(t("Risk preference", "风险偏好")) {
                Picker(t("Risk preference", "风险偏好"), selection: $riskPreference) {
                    Text(t("Conservative", "保守")).tag("conservative")
                    Text(t("Medium", "中等")).tag("medium")
                    Text(t("Aggressive", "激进")).tag("aggressive")
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle(t("Elite profile", "Elite 画像"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(t("Save", "保存")) {
                    let tags = skillTagsText
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    EliteProfileStore.save(EliteProfile(
                        industryExperience: industryExperience,
                        skillTags: tags,
                        weeklyHours: weeklyHours,
                        budgetUSD: budgetUSD,
                        riskPreference: riskPreference
                    ))
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EliteProfileView(existing: EliteProfileStore.load())
    }
}

