import SwiftUI

struct SignalsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = SignalsViewModel()

    var body: some View {
        NavigationStack {
            List {
                if let updatedAt = vm.updatedAt {
                    Section {
                        Text("最近更新时间：\(updatedAt, style: .time)")
                            .foregroundStyle(.secondary)
                    }
                }

                if appState.subscriptionManager.tier == .free {
                    Section {
                        UpgradeCTAView(
                            title: "Free：每天最多滑动查看 30 条",
                            message: "升级 Pro 后可无限浏览全部 Signals，并查看 Today 完整结论与行动建议"
                        )
                    }
                }

                Section {
                    Picker("类型", selection: Binding(
                        get: { vm.selectedType },
                        set: { newValue in
                            vm.selectedType = newValue
                            Task { await vm.loadFirstPage(accessToken: appState.authSession.accessToken) }
                        }
                    )) {
                        Text("全部").tag(SignalType?.none)
                        ForEach(SignalType.allCases) { t in
                            Text(t.rawValue).tag(Optional(t))
                        }
                    }

                    TextField("行业关键词（可选）", text: $vm.industryKeyword)
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            Task { await vm.loadFirstPage(accessToken: appState.authSession.accessToken) }
                        }
                }

                Section("信号") {
                    let shown = shownSignals
                    if shown.isEmpty && vm.isLoading {
                        Text("加载中…")
                            .foregroundStyle(.secondary)
                    } else if shown.isEmpty {
                        Text("暂无信号")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(shown) { s in
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
                            .onAppear {
                                guard appState.subscriptionManager.tier >= .pro else { return }
                                if s.id == vm.signals.last?.id, vm.nextCursor != nil {
                                    Task { await vm.loadMore(accessToken: appState.authSession.accessToken) }
                                }
                            }
                        }

                        if appState.subscriptionManager.tier == .free, vm.signals.count > 30 {
                            Text("已达今日上限（30 条）。升级 Pro 解锁更多。")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Signals")
            .navigationDestination(for: Signal.self) { s in
                SignalDetailView(signal: s)
            }
        }
        .task(id: appState.refreshTick) {
            await vm.loadFirstPage(accessToken: appState.authSession.accessToken)
        }
        .refreshable {
            await vm.loadFirstPage(accessToken: appState.authSession.accessToken)
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

    private var shownSignals: [Signal] {
        if AppConfig.isMockMode {
            return vm.signals
        }
        if appState.subscriptionManager.tier == .free {
            return Array(vm.signals.prefix(30))
        }
        return vm.signals
    }
}

#Preview {
    SignalsView()
        .environmentObject(AppState())
}

