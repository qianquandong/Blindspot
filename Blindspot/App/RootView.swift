import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if appState.authSession.isAuthenticated || appState.authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            appState.startHourlyRefreshTimer()
        }
        .task {
            // 只有在“没有 Supabase 配置”的情况下，才自动进入本地 Demo。
            // 否则用户点“退出登录”会立刻被这个逻辑又塞回 demo，看起来像退出失败。
            if AppConfig.isMockMode,
               SupabaseClientProvider.shared == nil,
               !appState.authSession.isAuthenticated,
               !appState.authManager.isAuthenticated {
                // 无后端 Demo：自动进入（Free 权限也可看全部内容）
                appState.authSession.setAccessToken("demo")
                appState.subscriptionManager.tier = .free
            }
            await appState.subscriptionManager.loadProducts()
            await appState.subscriptionManager.refreshEntitlements()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                appState.startHourlyRefreshTimer()
                Task {
                    await appState.authManager.refreshSession()
                    await appState.subscriptionManager.refreshEntitlements()
                }
            default:
                appState.stopHourlyRefreshTimer()
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}

