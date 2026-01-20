import Foundation
import Supabase

enum SupabaseClientProvider {
    static let shared: SupabaseClient? = {
        let urlString = (Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String)
            ?? SupabaseConfig.urlString
        let key = (Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String)
            ?? SupabaseConfig.anonKey

        guard
              let url = URL(string: urlString),
              !key.isEmpty
        else {
            return nil
        }

        // 说明：
        // - autoRefreshToken: 让 SDK 自动刷新 token
        // - emitLocalSessionAsInitialSession: 立即发出本地 session（避免 SDK 打印“legacy initial session”提示）
        let options = SupabaseClientOptions(
            auth: .init(
                autoRefreshToken: true,
                emitLocalSessionAsInitialSession: true
            )
        )
        return SupabaseClient(supabaseURL: url, supabaseKey: key, options: options)
    }()
}

