import SwiftUI

struct SignalDetailView: View {
    let signal: Signal
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        let t = { (en: String, zh: String) in SRL10n.t(en: en, zhHans: zh, lang: appLanguage) }

        return ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                SRCardSectionView(icon: "🧾", title: t("Summary", "事实摘要"), text: signal.summary)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Text("🏷️").font(.title3)
                        Text(t("Industry / Type", "行业 / 类型")).font(.headline)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        LabeledContent(t("Industry", "行业"), value: signal.industry)
                        LabeledContent(t("Type", "类型"), value: signal.signalType.rawValue)
                        if let c = signal.confidenceScore {
                            LabeledContent(t("Confidence", "置信度"), value: String(format: "%.2f", c))
                        }
                        LabeledContent(t("Date", "日期"), value: signal.date.yyyyMMddUTCString())
                    }
                    .font(.subheadline)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 0.5)
                )

                if let impact = signal.impact, !impact.isEmpty {
                    SRCardSectionView(icon: "📌", title: t("Potential impact", "可能影响"), text: impact)
                }
                if let evidence = signal.evidence, !evidence.isEmpty {
                    SRCardSectionView(icon: "🔗", title: t("Evidence / Sources", "证据 / 来源"), text: evidence)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle("Signal")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SignalDetailView(signal: Signal(
            signalId: "s1",
            date: Date(),
            industry: "AI",
            signalType: .emerging,
            summary: "A new metric is improving rapidly…",
            evidence: "Source: a research report",
            impact: "This may reduce costs and enable new product forms",
            confidenceScore: 0.72
        ))
    }
}

