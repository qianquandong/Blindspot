import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if appState.authSession.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            appState.startHourlyRefreshTimer()
        }
        .task {
            if AppConfig.isMockMode, !appState.authSession.isAuthenticated {
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
                Task { await appState.subscriptionManager.refreshEntitlements() }
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

