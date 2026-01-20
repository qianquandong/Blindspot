import Combine
import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var authSession: AuthSession
    @Published var authManager: AuthManager
    @Published var subscriptionManager: SubscriptionManager

    /// 用于驱动“每小时自动刷新”的轻量 tick（前台时更新）
    @Published var refreshTick: Int = 0

    private var hourlyTimer: Timer?
    private var cancellables: Set<AnyCancellable> = []

    convenience init() {
        self.init(authSession: AuthSession(), authManager: AuthManager(), subscriptionManager: SubscriptionManager())
    }

    init(authSession: AuthSession, authManager: AuthManager, subscriptionManager: SubscriptionManager) {
        self.authSession = authSession
        self.authManager = authManager
        self.subscriptionManager = subscriptionManager

        // 转发子对象变化，确保 RootView 等依赖 appState 的 UI 能及时刷新
        authSession.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        authManager.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        subscriptionManager.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    func startHourlyRefreshTimer() {
        stopHourlyRefreshTimer()
        hourlyTimer = Timer.scheduledTimer(withTimeInterval: 60 * 60, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in self.refreshTick &+= 1 }
        }
    }

    func stopHourlyRefreshTimer() {
        hourlyTimer?.invalidate()
        hourlyTimer = nil
    }
}

