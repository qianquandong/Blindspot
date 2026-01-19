import SwiftUI

struct StrategicTopicDetailView: View {
    let topic: StrategicTopic

    @Environment(\.openURL) private var openURL
    @State private var copiedToast: Bool = false
    @State private var copiedMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header

                SRCardSectionView(icon: "🧬", title: "第一性原理", text: topic.firstPrinciples)
                SRCardSectionView(icon: "💰", title: "商业机会", text: topic.businessOpportunity)
                SRCardSectionView(icon: "🗺️", title: "未来路线", text: topic.futureRoadmap)

                Spacer(minLength: 12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle("话题")
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
        VStack(alignment: .leading, spacing: 10) {
            Text(topic.topicName)
                .font(.title2.weight(.bold))
                .lineSpacing(2)
                .textSelection(.enabled)

            if !topic.sourceTitle.isEmpty {
                Text("来源：\(topic.sourceTitle)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 0.5)
        )
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

