import SwiftUI

struct StrategicTopicDetailView: View {
    let topic: StrategicTopic

    @Environment(\.openURL) private var openURL
    @State private var copiedToast: Bool = false
    @State private var copiedMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SRTheme.Spacing.l) {
                header
                    .padding(.top, 6)

                SRCardSectionView(icon: "🧬", title: "第一性原理", text: topic.firstPrinciples, tint: .purple)
                SRCardSectionView(icon: "💰", title: "商业机会", text: topic.businessOpportunity, tint: .green)
                SRCardSectionView(icon: "🗺️", title: "未来路线", text: topic.futureRoadmap, tint: .blue)

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
                Button("打开原文") {
                    if let url = URL(string: topic.sourceLink) {
                        openURL(url)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("复制：第一性原理") { copy(topic.firstPrinciples, label: "第一性原理") }
                    Button("复制：商业机会") { copy(topic.businessOpportunity, label: "商业机会") }
                    Button("复制：未来路线") { copy(topic.futureRoadmap, label: "未来路线") }
                    Button("复制：整条话题") {
                        let all = """
                        \(topic.topicName)

                        🧬 第一性原理:
                        \(topic.firstPrinciples)

                        💰 商业机会:
                        \(topic.businessOpportunity)

                        🗺️ 未来路线:
                        \(topic.futureRoadmap)
                        """
                        copy(all, label: "整条话题")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("已复制", isPresented: $copiedToast) {
            Button("知道了", role: .cancel) { copiedToast = false }
        } message: {
            Text(copiedMessage)
        }
    }

    private var header: some View {
        SRHeroCard(background: SRTheme.pastelLavender) {
            VStack(alignment: .leading, spacing: 10) {
                Text("话题")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SRTheme.secondaryText)

                Text(topic.topicName)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(SRTheme.title)
                    .lineSpacing(5)
                    .textSelection(.enabled)

                if !topic.sourceTitle.isEmpty {
                    Text("来源：\(topic.sourceTitle)")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(SRTheme.secondaryText)
                }
            }
        }
    }

    private func copy(_ text: String, label: String) {
        UIPasteboard.general.string = text
        copiedMessage = "已复制：\(label)"
        copiedToast = true
    }
}

#Preview {
    NavigationStack {
        StrategicTopicDetailView(topic: StrategicTopic(
            sourceTitle: "资讯摘要",
            sourceLink: "https://feeds.nbcnews.com/nbcnews/public/news",
            topicName: "示例话题：为什么它值得关注？",
            firstPrinciples: "底层规律拆解…",
            businessOpportunity: "具体可做的产品/服务…",
            futureRoadmap: "1 个月行动 + 2 年规划…"
        ))
    }
}

