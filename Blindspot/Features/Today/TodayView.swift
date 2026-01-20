import UIKit
import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = TodayViewModel()
    @State private var copiedToast: Bool = false
    @State private var demoFeed: DemoFeed = .curated
    @AppStorage("demoBannerDismissed") private var demoBannerDismissed: Bool = false
    @Environment(\.appLanguage) private var appLanguage

    private func tr(_ en: String, _ zh: String) -> String {
        SRL10n.t(en: en, zhHans: zh, lang: appLanguage)
    }

    var body: some View {
        return NavigationStack {
            content
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DatePicker("", selection: $vm.selectedDate, displayedComponents: [.date])
                        .labelsHidden()
                }
                if AppConfig.isMockMode {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(tr("Copy email HTML", "复制邮件HTML")) {
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
        .alert(tr("Copied", "已复制"), isPresented: $copiedToast) {
            Button(tr("OK", "知道了"), role: .cancel) { copiedToast = false }
        } message: {
            Text(tr("Email HTML copied to clipboard.", "邮件 HTML 已复制到剪贴板，可直接粘贴到邮件发送。"))
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
                    VStack(alignment: .leading, spacing: SRTheme.Spacing.l) {
                        todayHeader
                        UpgradeCTAView(
                            title: tr("Unlock Today (Pro)", "解锁今日创业指南（Pro）"),
                            message: tr("Upgrade to see the daily conclusion, opportunities/risks, suggested actions, and 30-day history.", "升级后可查看：今日一句结论、新机会/高风险赛道、行动建议，以及 30 天游览")
                        )
                        if SupabaseClientProvider.shared != nil {
                            SRCardSectionView(
                                icon: "🧭",
                                title: tr("Today's opportunity (preview)", "今日机会（免费预览）"),
                                text: vm.dailyOpportunities.first?.summary ?? (vm.isLoading ? tr("Loading…", "加载中…") : tr("No data", "暂无数据")),
                                tint: .blue
                            )
                        } else {
                            Text(tr("Free users don't see conclusions/actions (per PRD).", "Free 用户不展示结论/建议（符合 PRD 权限）"))
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
                .background(SRTheme.background)

            case .pro, .elite:
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: SRTheme.Spacing.xl) {
                        todayHeader

                        if SupabaseClientProvider.shared != nil {
                            proEliteSupabaseCards
                        } else {
                            proEliteBriefCards
                        }

                        if let updatedAt = vm.brief?.updatedAt {
                            Text(String(format: tr("Last updated: %@", "最近更新时间：%@"), updatedAt.formatted(date: .omitted, time: .shortened)))
                                .font(.footnote)
                                .foregroundStyle(SRTheme.secondaryText)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 28)
                }
                .background(SRTheme.background)
                .navigationDestination(for: Signal.self) { s in
                    SignalDetailView(signal: s)
                }
                .refreshable {
                    await refreshIfNeeded(force: true)
                }
                .alert(tr("Load failed", "加载失败"), isPresented: Binding(
                    get: { vm.errorMessage != nil },
                    set: { isPresented in if !isPresented { vm.errorMessage = nil } }
                )) {
                    Button(tr("OK", "知道了"), role: .cancel) { vm.errorMessage = nil }
                } message: {
                    Text(vm.errorMessage ?? "")
                }
            }
        }
    }

    private var todayHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(SRTheme.heroTitleFont())
                .foregroundStyle(SRTheme.title)
                .lineLimit(2)

            Text(vm.selectedDate, style: .date)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SRTheme.secondaryText)
        }
        .padding(.top, 6)
    }

    private var proEliteSupabaseCards: some View {
        return VStack(alignment: .leading, spacing: SRTheme.Spacing.m) {
            Text(tr("Today's opportunities", "今日机会"))
                .font(SRTheme.sectionTitleFont())
                .foregroundStyle(SRTheme.title)

            if vm.dailyOpportunities.isEmpty {
                SRCard(background: SRTheme.pastelBlue.opacity(0.55)) {
                    Text(vm.isLoading ? tr("Loading…", "加载中…") : tr("No data", "暂无数据"))
                        .foregroundStyle(SRTheme.body)
                }
            } else {
                VStack(spacing: SRTheme.Spacing.l) {
                    ForEach(vm.dailyOpportunities) { o in
                        SRCard(background: SRTheme.pastelLavender.opacity(0.62)) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(o.title ?? tr("Untitled", "未命名"))
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(SRTheme.title)

                                if let s = o.summary, !s.isEmpty {
                                    Text(s)
                                        .foregroundStyle(SRTheme.body)
                                        .lineSpacing(5)
                                }

                                if let source = o.sourceTitle ?? o.sourceUrl {
                                    Text(source)
                                        .font(.footnote)
                                        .foregroundStyle(SRTheme.secondaryText)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var proEliteBriefCards: some View {
        return VStack(alignment: .leading, spacing: SRTheme.Spacing.xl) {
            SRHeroCard(background: SRTheme.pastelLavender) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(tr("Daily conclusion", "今日结论"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SRTheme.secondaryText)
                    Text(vm.brief?.dailyConclusion ?? (vm.isLoading ? tr("Loading…", "加载中…") : tr("No data", "暂无数据")))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(SRTheme.title)
                        .lineSpacing(6)
                        .textSelection(.enabled)
                }
            }

            pastelSignalSection(
                title: tr("Opportunities", "新机会"),
                background: SRTheme.pastelLavender.opacity(0.68),
                emptyText: vm.isLoading ? tr("Loading…", "加载中…") : tr("No opportunities", "暂无机会"),
                items: vm.brief?.opportunities ?? []
            )

            pastelSignalSection(
                title: tr("Risks", "高风险赛道"),
                background: SRTheme.pastelMint.opacity(0.68),
                emptyText: vm.isLoading ? tr("Loading…", "加载中…") : tr("No risks", "暂无风险"),
                items: vm.brief?.risks ?? []
            )

            if let actions = vm.brief?.suggestedActions, !actions.isEmpty {
                VStack(alignment: .leading, spacing: SRTheme.Spacing.m) {
                    Text(tr("Suggested actions", "行动建议"))
                        .font(SRTheme.sectionTitleFont())
                        .foregroundStyle(SRTheme.title)

                    SRCard(background: SRTheme.pastelBlue.opacity(0.55)) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(actions, id: \.self) { a in
                                Text("• \(a)")
                                    .foregroundStyle(SRTheme.body)
                                    .lineSpacing(4)
                            }
                        }
                    }
                }
            }
        }
    }

    private func pastelSignalSection(
        title: String,
        background: Color,
        emptyText: String,
        items: [Signal]
    ) -> some View {
        return VStack(alignment: .leading, spacing: SRTheme.Spacing.m) {
            Text(title)
                .font(SRTheme.sectionTitleFont())
                .foregroundStyle(SRTheme.title)

            if items.isEmpty {
                SRCard(background: background) {
                    Text(emptyText)
                        .foregroundStyle(SRTheme.body)
                }
            } else {
                VStack(spacing: SRTheme.Spacing.l) {
                    ForEach(items) { s in
                        NavigationLink(value: s) {
                            SRCard(background: background) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(s.summary)
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(SRTheme.title)
                                        .lineLimit(3)
                                        .lineSpacing(4)

                                    HStack(spacing: 10) {
                                        Text(s.industry)
                                        Text(s.signalType.rawValue)
                                        if let c = s.confidenceScore {
                                            Text(String(format: tr("Confidence %@", "置信度 %@"), String(format: "%.2f", c)))
                                        }
                                    }
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(SRTheme.secondaryText)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var demoReportContent: some View {
        return ScrollView {
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
                            title: vm.isLoading ? tr("Loading…", "加载中…") : tr("No content", "暂无内容"),
                            text: vm.isLoading ? tr("Reading local Demo report…", "正在读取本地 Demo 报告…") : tr("No topics to show.", "没有可展示的话题。"),
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
        .alert(tr("Load failed", "加载失败"), isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { isPresented in if !isPresented { vm.errorMessage = nil } }
        )) {
            Button(tr("OK", "知道了"), role: .cancel) { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    private var filteredDemoTopics: [StrategicTopic] {
        let all = vm.strategicReport?.topics ?? []
        switch demoFeed {
        case .curated:
            return all.filter { $0.sourceTitle == "News summary" }
        case .nbc:
            return all.filter { $0.sourceTitle == "NBC RSS" }
        case .all:
            return all
        }
    }

    private var filterStickyHeader: some View {
        return VStack(alignment: .leading, spacing: 10) {
            Text(tr("Daily strategic insights", "每日深度战略洞察"))
                .font(.title3.weight(.bold))
                .padding(.horizontal, 16)
                .padding(.top, 10)

            Picker(tr("Source", "来源"), selection: $demoFeed) {
                Text(tr("Curated", "精选摘要")).tag(DemoFeed.curated)
                Text("NBC RSS").tag(DemoFeed.nbc)
                Text(tr("All", "全部")).tag(DemoFeed.all)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
    }

    private var demoBanner: some View {
        return SRCard(background: SRTheme.pastelBlue.opacity(0.55)) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundStyle(SRTheme.secondaryText)

                VStack(alignment: .leading, spacing: 6) {
                    Text(tr("Local Demo (no backend)", "本地 Demo（不连后端）"))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(SRTheme.title)
                    Text(tr("Each news item is a topic. Use the filter above to switch sources.", "每条新闻=独立话题；可用顶部筛选切换来源。"))
                        .font(.subheadline)
                        .foregroundStyle(SRTheme.secondaryText)
                        .lineSpacing(3)
                }

                Spacer(minLength: 0)

                Button {
                    demoBannerDismissed = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SRTheme.secondaryText)
                        .padding(8)
                        .background(SRTheme.surface.opacity(0.65))
                        .clipShape(Circle())
                }
            }
        }
    }

    private func demoTopicCard(_ t: StrategicTopic) -> some View {
        return SRCard(background: SRTheme.pastelLavender.opacity(0.55)) {
            VStack(alignment: .leading, spacing: 12) {
                Text(t.topicName)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(SRTheme.title)
                    .lineLimit(3)
                    .lineSpacing(3)

                Divider().opacity(0.25)

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        SRBadgeView(icon: "🧬", title: self.tr("First principles", "第一性原理"), tint: .purple)
                        Text(t.firstPrinciples)
                            .font(.subheadline)
                            .foregroundStyle(SRTheme.body)
                            .lineSpacing(5)
                            .lineLimit(4)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SRBadgeView(icon: "💰", title: self.tr("Business opportunity", "商业机会"), tint: .green)
                        Text(t.businessOpportunity)
                            .font(.subheadline)
                            .foregroundStyle(SRTheme.body)
                            .lineSpacing(5)
                            .lineLimit(4)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SRBadgeView(icon: "🗺️", title: self.tr("Roadmap", "未来路线"), tint: .blue)
                        Text(t.futureRoadmap)
                            .font(.subheadline)
                            .foregroundStyle(SRTheme.body)
                            .lineSpacing(5)
                            .lineLimit(3)
                    }
                }
            }
        }
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

