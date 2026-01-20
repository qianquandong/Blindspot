import SwiftUI

struct EliteProfileView: View {
    @Environment(\.dismiss) private var dismiss

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
        _riskPreference = State(initialValue: existing?.riskPreference ?? "中等")
    }

    var body: some View {
        Form {
            Section("行业经验") {
                TextField("例如：SaaS / 电商 / 教育", text: $industryExperience)
            }

            Section("技能标签") {
                TextField("用逗号分隔，例如：编程, 自动化, 运营", text: $skillTagsText)
                    .textInputAutocapitalization(.never)
            }

            Section("可投入时间（每周）") {
                Stepper("\(weeklyHours) 小时", value: $weeklyHours, in: 0...80)
            }

            Section("预算（USD）") {
                Stepper("\(budgetUSD)", value: $budgetUSD, in: 0...1_000_000, step: 50)
            }

            Section("风险偏好") {
                Picker("风险偏好", selection: $riskPreference) {
                    Text("保守").tag("保守")
                    Text("中等").tag("中等")
                    Text("激进").tag("激进")
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Elite 画像")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
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

