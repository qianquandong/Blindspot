import Foundation
import Supabase

enum UsageService {
    struct IncrementUsageResponse: Decodable {
        let allowed: Bool
        let used: Int?
        let limit: Int?
    }

    /// 记录一次 Signals 浏览（Free 额度用）。如果后端尚未创建 `increment_usage` RPC，会返回 nil 并降级为本地计数。
    @MainActor
    static func incrementSignalsUsage(by inc: Int = 1) async -> IncrementUsageResponse? {
        guard let client = SupabaseClientProvider.shared else { return nil }

        let day = Date().yyyyMMddUTCString()

        do {
            // 约定：increment_usage(p_date text/date, p_inc int, p_feature text) -> {allowed, used, limit}
            let resp: IncrementUsageResponse = try await client
                .rpc("increment_usage", params: ["p_date": day, "p_inc": "\(inc)", "p_feature": "signals"])
                .single()
                .execute()
                .value
            return resp
        } catch {
            // 后端还没建 RPC 或 RLS/权限未通：直接降级，不影响本地 30 条限制
            #if DEBUG
            print("[UsageService] increment_usage failed: \(error)")
            #endif
            return nil
        }
    }
}

