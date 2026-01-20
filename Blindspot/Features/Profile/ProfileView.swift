import StoreKit
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var eliteProfile: EliteProfile? = EliteProfileStore.load()
    @Environment(\.openURL) private var openURL
    @State private var purchaseLoadingProductId: String?

    var body: some View {
        NavigationStack {
            List {
                Section("账号") {
                    Text((appState.authSession.isAuthenticated || appState.authManager.isAuthenticated) ? "已登录" : "未登录")
                }

                Section("订阅") {
                    HStack {
                        Text("当前档位")
                        Spacer()
                        Text(appState.subscriptionManager.tier.rawValue)
                            .foregroundStyle(.secondary)
                    }
                    Button("刷新权益") {
                        Task { await appState.subscriptionManager.refreshEntitlements() }
                    }
                    Button("管理订阅（App Store）") {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            openURL(url)
                        }
                    }
                    Button("恢复购买") {
                        Task { await appState.subscriptionManager.restorePurchases() }
                    }
                }

#if DEBUG
                Section("调试（无后端 / 无 App Store 产品时使用）") {
                    Picker("强制档位", selection: $appState.subscriptionManager.tier) {
                        Text("Free").tag(SubscriptionTier.free)
                        Text("Pro").tag(SubscriptionTier.pro)
                        Text("Elite").tag(SubscriptionTier.elite)
                    }
                }
#endif

                Section("升级") {
                    if appState.subscriptionManager.products.isEmpty {
                        Text(appState.subscriptionManager.isLoading ? "加载中…" : "暂无可购买产品（请检查产品 ID）")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(appState.subscriptionManager.products, id: \.id) { p in
                            Button {
                                purchaseLoadingProductId = p.id
                                Task {
                                    await appState.subscriptionManager.purchase(p)
                                    purchaseLoadingProductId = nil
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(p.displayName)
                                        Text(p.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }
                                    Spacer()
                                    if purchaseLoadingProductId == p.id {
                                        ProgressView()
                                    } else {
                                        Text(p.displayPrice)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .disabled(purchaseLoadingProductId != nil)
                        }
                    }
                }

                Section("Elite") {
                    NavigationLink {
                        EliteProfileView(existing: eliteProfile)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("编辑创业画像")
                            Text(eliteProfileSummary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(appState.subscriptionManager.tier < .elite)

                    if appState.subscriptionManager.tier < .elite {
                        Text("升级到 Elite 后可填写画像并获得个性化方向（MVP 先做基础表单）")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        // 兼容两种登录方式：旧的 authSession（自建 API token）+ Supabase session
                        appState.authSession.signOut()
                        Task { await appState.authManager.signOut() }
                    } label: {
                        Text("退出登录")
                    }
                }
            }
            .navigationTitle("Profile")
        }
        .task {
            await appState.subscriptionManager.refreshEntitlements()
            eliteProfile = EliteProfileStore.load()
        }
        .onAppear {
            eliteProfile = EliteProfileStore.load()
        }
        .alert("订阅错误", isPresented: Binding(
            get: { appState.subscriptionManager.lastErrorMessage != nil },
            set: { isPresented in
                if !isPresented { appState.subscriptionManager.lastErrorMessage = nil }
            }
        )) {
            Button("知道了", role: .cancel) { appState.subscriptionManager.lastErrorMessage = nil }
        } message: {
            Text(appState.subscriptionManager.lastErrorMessage ?? "")
        }
    }

    private var eliteProfileSummary: String {
        guard let eliteProfile else { return "未填写" }
        let tags = eliteProfile.skillTags.prefix(3).joined(separator: " / ")
        return "\(eliteProfile.industryExperience.isEmpty ? "行业未填" : eliteProfile.industryExperience) · \(tags.isEmpty ? "技能未填" : tags)"
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}

