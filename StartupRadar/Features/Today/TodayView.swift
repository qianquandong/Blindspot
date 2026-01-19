import UIKit
import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = TodayViewModel()
    @State private var copiedToast: Bool = false
    @State private var demoFeed: DemoFeed = .curated

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
                        Text("Free 用户不展示结论/建议（符合 PRD 权限）")
                            .foregroundStyle(.secondary)
                        Spacer(minLength: 0)
                    }
                    .padding()
                }

            case .pro, .elite:
                List {
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
            VStack(alignment: .leading, spacing: 14) {
                headerCard

                let topics = filteredDemoTopics
                if !topics.isEmpty {
                    LazyVStack(spacing: 12) {
                        ForEach(topics) { t in
                            NavigationLink(value: t) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(t.topicName)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                        .lineLimit(3)
                                        .lineSpacing(2)

                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("🧬 第一性原理")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                        Text(t.firstPrinciples)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(4)
                                            .lineSpacing(3)

                                        Text("💰 商业机会")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                        Text(t.businessOpportunity)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(4)
                                            .lineSpacing(3)

                                        Text("🗺️ 未来路线")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                        Text(t.futureRoadmap)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(3)
                                            .lineSpacing(3)
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
                            .buttonStyle(.plain)
                        }
                    }
                } else {
                    SRCardSectionView(
                        icon: "⏳",
                        title: vm.isLoading ? "加载中…" : "暂无内容",
                        text: vm.isLoading ? "正在读取本地 Demo 报告…" : "没有可展示的话题。"
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("每日深度战略洞察（Demo）")
                .font(.title3.weight(.bold))
            Text("来源：\(vm.strategicReport?.source.name ?? "NBC News Top Stories")")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Picker("来源", selection: $demoFeed) {
                Text("精选摘要").tag(DemoFeed.curated)
                Text("NBC RSS").tag(DemoFeed.nbc)
                Text("全部").tag(DemoFeed.all)
            }
            .pickerStyle(.segmented)

            Text("当前为本地 Demo（不连后端）。你看到“只有一个 feed”的原因是之前所有条目都标成同一个来源；现在可按来源筛选。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
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

    private func refreshIfNeeded(force: Bool = false) async {
        // Mock 模式：Free 也展示全部
        if !AppConfig.isMockMode {
            guard appState.subscriptionManager.tier >= .pro else { return }
        }
        if force || vm.brief == nil {
            await vm.load(accessToken: appState.authSession.accessToken)
        } else {
            // 每小时 tick 也触发一次刷新（MVP 简化：直接刷新）
            await vm.load(accessToken: appState.authSession.accessToken)
        }
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

