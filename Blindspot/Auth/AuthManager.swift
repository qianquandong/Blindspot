import Combine
import Foundation
import Supabase

@MainActor
final class AuthManager: ObservableObject {
    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var currentUserId: UUID?

    private let client: SupabaseClient?

    init(client: SupabaseClient? = nil) {
        self.client = client ?? SupabaseClientProvider.shared
        Task { await refreshSession() }
    }

    func refreshSession() async {
        guard let client else {
            isAuthenticated = false
            currentUserId = nil
            return
        }

        do {
            let session = try await client.auth.session
            // 保险：即使 SDK 发出了本地 session，也不要把过期 session 当成“已登录”
            if session.isExpired {
                isAuthenticated = false
                currentUserId = nil
                return
            }
            isAuthenticated = true
            currentUserId = session.user.id
        } catch {
            isAuthenticated = false
            currentUserId = nil
        }
    }

    func sendEmailOTP(to email: String) async throws {
        guard let client else { throw NSError(domain: "Supabase", code: 0, userInfo: [NSLocalizedDescriptionKey: "Supabase 未配置"]) }
        // Email OTP: 发送 6 位验证码到邮箱
        try await client.auth.signInWithOTP(email: email)
    }

    func verifyEmailOTP(email: String, code: String) async throws {
        guard let client else { throw NSError(domain: "Supabase", code: 0, userInfo: [NSLocalizedDescriptionKey: "Supabase 未配置"]) }

        // 验证 6 位验证码（Email）
        // Supabase 发送的邮件类型会因用户是否首次注册而不同：
        // - 首次注册：signup
        // - 已有用户登录：magiclink
        // 我们按顺序尝试，兼容不同模板/配置。
        let typesToTry: [EmailOTPType] = [.magiclink, .signup, .email]
        var lastError: Error?
        for t in typesToTry {
            do {
                _ = try await client.auth.verifyOTP(email: email, token: code, type: t)
                lastError = nil
                break
            } catch {
                lastError = error
            }
        }
        if let lastError { throw lastError }

        await refreshSession()
        try await bootstrapProfileIfNeeded()
    }

    func signOut() async {
        guard let client else { return }
        do {
            try await client.auth.signOut()
        } catch {
            // ignore
        }
        await refreshSession()
    }

    // MARK: - Profile bootstrap

    private struct ProfileRow: Encodable {
        let id: UUID
        let displayName: String?

        enum CodingKeys: String, CodingKey {
            case id
            case displayName = "display_name"
        }
    }

    private func bootstrapProfileIfNeeded() async throws {
        guard let client, let userId = currentUserId else { return }
        // 首次登录建档：若已存在则 merge（onConflict: id）
        _ = try await client
            .from("profiles")
            .upsert(ProfileRow(id: userId, displayName: nil), onConflict: "id", returning: .minimal)
            .execute()
    }
}

