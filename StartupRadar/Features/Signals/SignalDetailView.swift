import SwiftUI

struct SignalDetailView: View {
    let signal: Signal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                SRCardSectionView(icon: "🧾", title: "事实摘要", text: signal.summary)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Text("🏷️").font(.title3)
                        Text("行业 / 类型").font(.headline)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        LabeledContent("行业", value: signal.industry)
                        LabeledContent("类型", value: signal.signalType.rawValue)
                        if let c = signal.confidenceScore {
                            LabeledContent("置信度", value: String(format: "%.2f", c))
                        }
                        LabeledContent("日期", value: signal.date.yyyyMMddUTCString())
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
                    SRCardSectionView(icon: "📌", title: "可能影响", text: impact)
                }
                if let evidence = signal.evidence, !evidence.isEmpty {
                    SRCardSectionView(icon: "🔗", title: "证据 / 来源", text: evidence)
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
            summary: "某项新技术指标快速提升…",
            evidence: "来源：某研究报告",
            impact: "可能导致成本下降与新产品形态出现",
            confidenceScore: 0.72
        ))
    }
}

