import Combine
import Foundation
import Supabase

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published private(set) var brief: DailyBrief?
    @Published private(set) var strategicReport: DailyStrategicReport?
    @Published private(set) var dailyOpportunities: [DailyOpportunity] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    private let client: APIClient
    private let supabase: SupabaseClient?

    convenience init() {
        self.init(client: APIClient())
    }

    init(client: APIClient, supabase: SupabaseClient? = nil) {
        self.client = client
        self.supabase = supabase ?? SupabaseClientProvider.shared
    }

    func load(accessToken: String?, supabaseUserId: UUID?) async {
        isLoading = true
        defer { isLoading = false }

        do {
            if AppConfig.isMockMode {
                // Demo：直接从 MockServer 返回的 DailyStrategicReport 解码
                let resp: DailyStrategicReport = try await client.request(
                    "/today",
                    accessToken: accessToken,
                    queryItems: [
                        URLQueryItem(name: "date", value: selectedDate.yyyyMMddUTCString())
                    ]
                )
                strategicReport = resp
                brief = nil
                dailyOpportunities = []
                errorMessage = nil
                return
            }

            if let supabase, supabaseUserId != nil {
                let day = selectedDate.yyyyMMddUTCString()
                let rows: [DailyOpportunity] = try await supabase
                    .from("daily_opportunities")
                    .select()
                    .eq("day", value: day)
                    .order("created_at", ascending: false)
                    .execute()
                    .value

                dailyOpportunities = rows
                brief = nil
                strategicReport = nil
                errorMessage = nil
                return
            }

            // TODO: 若后端路径不同，请改这里
            let resp: DailyBrief = try await client.request(
                "/today",
                accessToken: accessToken,
                queryItems: [
                    URLQueryItem(name: "date", value: selectedDate.yyyyMMddUTCString())
                ]
            )
            brief = resp
            strategicReport = nil
            dailyOpportunities = []
            errorMessage = nil
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}

