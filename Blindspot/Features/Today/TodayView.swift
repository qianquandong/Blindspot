import UIKit
import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = TodayViewModel()
    @State private var copiedToast: Bool = false
    @State private var demoFeed: DemoFeed = .curated
    @AppStorage("demoBannerDismissed") private var demoBannerDismissed: Bool = false

    var body: some View {
        NavigationStack {
            content
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DatePicker("", selection: $vm.selectedDate, displayedComponents: [.date])
                        .labelsHidden()
                }
                if AppConfig.isMockMode {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("复制邮件HTML") {
                            UIPasteboard.general.string = DemoReportStore.nbcEmailHTML()
                            copiedToast = true
                        }
                    }
                }
            }
        }
        .task(id: appState.refreshTick) {
            await refreshIfNeeded()
        }
        .onChange(of: vm.selectedDate) { _, _ in
            Task { await refreshIfNeeded() }
        }
        .alert("已复制", isPresented: $copiedToast) {
            Button("知道了", role: .cancel) { copiedToast = false }
        } message: {
            Text("邮件 HTML 已复制到剪贴板，可直接粘贴到邮件发送。")
        }
    }

    @ViewBuilder
    private var content: some View {
        if AppConfig.isMockMode {
            demoReportContent
        } else {
            switch appState.subscriptionManager.tier {
            case .free:
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        UpgradeCTAView(
                            title: "解锁今日创业指南（Pro）",
                            message: "升级后可查看：今日一句结论、新机会/高风险赛道、行动建议，以及 30 天游览"
                        )
                        if SupabaseClientProvider.shared != nil {
                            SRCardSectionView(
                                icon: "🧭",
                                title: "今日机会（免费预览）",
                                text: vm.dailyOpportunities.first?.summary ?? (vm.isLoading ? "加载中…" : "暂无数据"),
                                tint: .blue
                            )
                        } else {
                            Text("Free 用户不展示结论/建议（符合 PRD 权限）")
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding()
                }

            case .pro, .elite:
                List {
                    if SupabaseClientProvider.shared != nil {
                        Section("今日机会") {
                            if vm.dailyOpportunities.isEmpty {
                                Text(vm.isLoading ? "加载中…" : "暂无数据")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(vm.dailyOpportunities) { o in
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(o.title ?? "未命名")
                                            .font(.headline)
                                        if let s = o.summary, !s.isEmpty {
                                            Text(s)
                                                .foregroundStyle(.secondary)
                                                .lineSpacing(4)
                                        }
                                        if let source = o.sourceTitle ?? o.sourceUrl {
                                            Text(source)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }

                    if let updatedAt = vm.brief?.updatedAt {
                        Section {
                            Text("最近更新时间：\(updatedAt, style: .time)")
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section("今日结论") {
                        Text(vm.brief?.dailyConclusion ?? (vm.isLoading ? "加载中…" : "暂无数据"))
                    }

                    Section("新机会") {
                        if let items = vm.brief?.opportunities, !items.isEmpty {
                            ForEach(items) { s in
                                NavigationLink(value: s) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(s.summary).lineLimit(2)
                                        HStack {
                                            Text(s.industry)
                                            Text(s.signalType.rawValue)
                                            if let c = s.confidenceScore {
                                                Text("置信度 \(String(format: "%.2f", c))")
                                            }
                                        }
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        } else {
                            Text(vm.isLoading ? "加载中…" : "暂无机会")
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section("高风险赛道") {
                        if let items = vm.brief?.risks, !items.isEmpty {
                            ForEach(items) { s in
                                NavigationLink(value: s) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(s.summary).lineLimit(2)
                                        HStack {
                                            Text(s.industry)
                                            Text(s.signalType.rawValue)
                                            if let c = s.confidenceScore {
                                                Text("置信度 \(String(format: "%.2f", c))")
                                            }
                                        }
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        } else {
                            Text(vm.isLoading ? "加载中…" : "暂无风险")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let actions = vm.brief?.suggestedActions, !actions.isEmpty {
                        Section("行动建议") {
                            ForEach(actions, id: \.self) { a in
                                Text("• \(a)")
                            }
                        }
                    }
                }
                .navigationDestination(for: Signal.self) { s in
                    SignalDetailView(signal: s)
                }
                .refreshable {
                    await refreshIfNeeded(force: true)
                }
                .alert("加载失败", isPresented: Binding(
                    get: { vm.errorMessage != nil },
                    set: { isPresented in if !isPresented { vm.errorMessage = nil } }
                )) {
                    Button("知道了", role: .cancel) { vm.errorMessage = nil }
                } message: {
                    Text(vm.errorMessage ?? "")
                }
            }
        }
    }

    private var demoReportContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12, pinnedViews: [.sectionHeaders]) {
                Section(header: filterStickyHeader) {
                    if !demoBannerDismissed {
                        demoBanner
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                    }

                    let topics = filteredDemoTopics
                    if topics.isEmpty {
                        SRCardSectionView(
                            icon: "⏳",
                            title: vm.isLoading ? "加载中…" : "暂无内容",
                            text: vm.isLoading ? "正在读取本地 Demo 报告…" : "没有可展示的话题。",
                            tint: .gray
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(topics) { t in
                                NavigationLink(value: t) {
                                    demoTopicCard(t)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .navigationDestination(for: StrategicTopic.self) { t in
            StrategicTopicDetailView(topic: t)
        }
        .refreshable { await refreshIfNeeded(force: true) }
        .alert("加载失败", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { isPresented in if !isPresented { vm.errorMessage = nil } }
        )) {
            Button("知道了", role: .cancel) { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    private var filteredDemoTopics: [StrategicTopic] {
        let all = vm.strategicReport?.topics ?? []
        switch demoFeed {
        case .curated:
            return all.filter { $0.sourceTitle == "资讯摘要" }
        case .nbc:
            return all.filter { $0.sourceTitle == "NBC RSS" }
        case .all:
            return all
        }
    }

    private var filterStickyHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("每日深度战略洞察")
                .font(.title3.weight(.bold))
                .padding(.horizontal, 16)
                .padding(.top, 10)

            Picker("来源", selection: $demoFeed) {
                Text("精选摘要").tag(DemoFeed.curated)
                Text("NBC RSS").tag(DemoFeed.nbc)
                Text("全部").tag(DemoFeed.all)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
    }

    private var demoBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.title3)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                Text("本地 Demo（不连后端）")
                    .font(.headline)
                Text("每条新闻=独立话题；可用顶部筛选切换来源。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
            }

            Spacer(minLength: 0)

            Button {
                demoBannerDismissed = true
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(Color(uiColor: .tertiarySystemBackground))
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)
    }

    private func demoTopicCard(_ t: StrategicTopic) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(t.topicName)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(3)
                .lineSpacing(3)

            Divider().opacity(0.3)

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    SRBadgeView(icon: "🧬", title: "第一性原理", tint: .purple)
                    Text(t.firstPrinciples)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(5)
                        .lineLimit(4)
                }

                VStack(alignment: .leading, spacing: 8) {
                    SRBadgeView(icon: "💰", title: "商业机会", tint: .green)
                    Text(t.businessOpportunity)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(5)
                        .lineLimit(4)
                }

                VStack(alignment: .leading, spacing: 8) {
                    SRBadgeView(icon: "🗺️", title: "未来路线", tint: .blue)
                    Text(t.futureRoadmap)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(5)
                        .lineLimit(3)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 8)
    }

    private func refreshIfNeeded(force: Bool = false) async {
        // Mock 模式：Free 也展示全部
        if AppConfig.isMockMode {
            await vm.load(accessToken: appState.authSession.accessToken, supabaseUserId: nil)
            return
        }

        // Supabase 模式：已登录即可拉取（用于展示/验证 RLS）
        if SupabaseClientProvider.shared != nil {
            await vm.load(accessToken: nil, supabaseUserId: appState.authManager.currentUserId)
            return
        }

        // API 模式（旧）：Pro/Elite 才加载
        guard appState.subscriptionManager.tier >= .pro else { return }
        await vm.load(accessToken: appState.authSession.accessToken, supabaseUserId: nil)
    }
}

private enum DemoFeed: String, CaseIterable, Identifiable {
    case curated
    case nbc
    case all

    var id: String { rawValue }
}

#Preview {
    TodayView()
        .environmentObject(AppState())
}

