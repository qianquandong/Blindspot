import StoreKit
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var eliteProfile: EliteProfile? = EliteProfileStore.load()
    @Environment(\.openURL) private var openURL
    @State private var purchaseLoadingProductId: String?
    @Environment(\.appLanguage) private var appLanguage
    @AppStorage("app_language") private var appLanguageRaw: String = AppLanguage.en.rawValue

    var body: some View {
        let t = { (en: String, zh: String) in SRL10n.t(en: en, zhHans: zh, lang: appLanguage) }

        return NavigationStack {
            List {
                Section(t("Account", "账号")) {
                    Text((appState.authSession.isAuthenticated || appState.authManager.isAuthenticated) ? t("Signed in", "已登录") : t("Signed out", "未登录"))
                }

                Section(t("Subscription", "订阅")) {
                    HStack {
                        Text(t("Current tier", "当前档位"))
                        Spacer()
                        Text(appState.subscriptionManager.tier.rawValue)
                            .foregroundStyle(.secondary)
                    }
                    Button(t("Refresh entitlements", "刷新权益")) {
                        Task { await appState.subscriptionManager.refreshEntitlements() }
                    }
                    Button(t("Manage subscriptions (App Store)", "管理订阅（App Store）")) {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            openURL(url)
                        }
                    }
                    Button(t("Restore purchases", "恢复购买")) {
                        Task { await appState.subscriptionManager.restorePurchases() }
                    }
                }

#if DEBUG
                Section(t("Debug (when no backend / no App Store products)", "调试（无后端 / 无 App Store 产品时使用）")) {
                    Picker(t("Force tier", "强制档位"), selection: $appState.subscriptionManager.tier) {
                        Text("Free").tag(SubscriptionTier.free)
                        Text("Pro").tag(SubscriptionTier.pro)
                        Text("Elite").tag(SubscriptionTier.elite)
                    }
                }
#endif

                Section(t("Upgrade", "升级")) {
                    if appState.subscriptionManager.products.isEmpty {
                        Text(appState.subscriptionManager.isLoading ? t("Loading…", "加载中…") : t("No purchasable products (check product IDs)", "暂无可购买产品（请检查产品 ID）"))
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
                            Text(t("Edit founder profile", "编辑创业画像"))
                            Text(eliteProfileSummary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(appState.subscriptionManager.tier < .elite)

                    if appState.subscriptionManager.tier < .elite {
                        Text(t("Upgrade to Elite to fill your profile and get personalized directions (MVP uses a basic form).", "升级到 Elite 后可填写画像并获得个性化方向（MVP 先做基础表单）"))
                            .foregroundStyle(.secondary)
                    }
                }

                Section(t("Settings", "设置")) {
                    Picker(t("Language", "语言"), selection: $appLanguageRaw) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang.rawValue)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        // 兼容两种登录方式：旧的 authSession（自建 API token）+ Supabase session
                        appState.authSession.signOut()
                        Task { await appState.authManager.signOut() }
                    } label: {
                        Text(t("Sign out", "退出登录"))
                    }
                }
            }
            .navigationTitle(t("Profile", "Profile"))
        }
        .task {
            await appState.subscriptionManager.refreshEntitlements()
            eliteProfile = EliteProfileStore.load()
        }
        .onAppear {
            eliteProfile = EliteProfileStore.load()
        }
        .alert(t("Subscription error", "订阅错误"), isPresented: Binding(
            get: { appState.subscriptionManager.lastErrorMessage != nil },
            set: { isPresented in
                if !isPresented { appState.subscriptionManager.lastErrorMessage = nil }
            }
        )) {
            Button(t("OK", "知道了"), role: .cancel) { appState.subscriptionManager.lastErrorMessage = nil }
        } message: {
            Text(appState.subscriptionManager.lastErrorMessage ?? "")
        }
    }

    private var eliteProfileSummary: String {
        let t = { (en: String, zh: String) in SRL10n.t(en: en, zhHans: zh, lang: appLanguage) }
        guard let eliteProfile else { return t("Not filled", "未填写") }
        let tags = eliteProfile.skillTags.prefix(3).joined(separator: " / ")
        return "\(eliteProfile.industryExperience.isEmpty ? t("Industry not set", "行业未填") : eliteProfile.industryExperience) · \(tags.isEmpty ? t("Skills not set", "技能未填") : tags)"
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}

