import SwiftUI

struct StrategicTopicDetailView: View {
    let topic: StrategicTopic

    @Environment(\.openURL) private var openURL
    @State private var copiedToast: Bool = false
    @State private var copiedMessage: String = ""
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        let t = { (en: String, zh: String) in SRL10n.t(en: en, zhHans: zh, lang: appLanguage) }

        return ScrollView {
            VStack(alignment: .leading, spacing: SRTheme.Spacing.l) {
                header
                    .padding(.top, 6)

                SRCardSectionView(icon: "🧬", title: t("First principles", "第一性原理"), text: topic.firstPrinciples, tint: .purple)
                SRCardSectionView(icon: "💰", title: t("Business opportunity", "商业机会"), text: topic.businessOpportunity, tint: .green)
                SRCardSectionView(icon: "🗺️", title: t("Roadmap", "未来路线"), text: topic.futureRoadmap, tint: .blue)

                Spacer(minLength: 12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(SRTheme.background)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(t("Open source", "打开原文")) {
                    if let url = URL(string: topic.sourceLink) {
                        openURL(url)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(t("Copy: First principles", "复制：第一性原理")) { copy(topic.firstPrinciples, label: t("First principles", "第一性原理")) }
                    Button(t("Copy: Business opportunity", "复制：商业机会")) { copy(topic.businessOpportunity, label: t("Business opportunity", "商业机会")) }
                    Button(t("Copy: Roadmap", "复制：未来路线")) { copy(topic.futureRoadmap, label: t("Roadmap", "未来路线")) }
                    Button(t("Copy: Entire topic", "复制：整条话题")) {
                        let all = """
                        \(topic.topicName)

                        🧬 \(t("First principles", "第一性原理")):
                        \(topic.firstPrinciples)

                        💰 \(t("Business opportunity", "商业机会")):
                        \(topic.businessOpportunity)

                        🗺️ \(t("Roadmap", "未来路线")):
                        \(topic.futureRoadmap)
                        """
                        copy(all, label: t("Entire topic", "整条话题"))
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert(t("Copied", "已复制"), isPresented: $copiedToast) {
            Button(t("OK", "知道了"), role: .cancel) { copiedToast = false }
        } message: {
            Text(copiedMessage)
        }
    }

    private var header: some View {
        let t = { (en: String, zh: String) in SRL10n.t(en: en, zhHans: zh, lang: appLanguage) }

        return SRHeroCard(background: SRTheme.pastelLavender) {
            VStack(alignment: .leading, spacing: 10) {
                Text(t("Topic", "话题"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SRTheme.secondaryText)

                Text(topic.topicName)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(SRTheme.title)
                    .lineSpacing(5)
                    .textSelection(.enabled)

                if !topic.sourceTitle.isEmpty {
                    Text(String(format: t("Source: %@", "来源：%@"), topic.sourceTitle))
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(SRTheme.secondaryText)
                }
            }
        }
    }

    private func copy(_ text: String, label: String) {
        let t = { (en: String, zh: String) in SRL10n.t(en: en, zhHans: zh, lang: appLanguage) }
        UIPasteboard.general.string = text
        copiedMessage = String(format: t("Copied: %@", "已复制：%@"), label)
        copiedToast = true
    }
}

#Preview {
    NavigationStack {
        StrategicTopicDetailView(topic: StrategicTopic(
            sourceTitle: "News summary",
            sourceLink: "https://feeds.nbcnews.com/nbcnews/public/news",
            topicName: "Sample topic: Why it matters",
            firstPrinciples: "Break down the underlying principles…",
            businessOpportunity: "What product/service you could build…",
            futureRoadmap: "1-month actions + 2-year roadmap…"
        ))
    }
}

