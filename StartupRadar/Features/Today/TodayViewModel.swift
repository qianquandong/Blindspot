import Combine
import Foundation

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published private(set) var brief: DailyBrief?
    @Published private(set) var strategicReport: DailyStrategicReport?
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    private let client: APIClient

    convenience init() {
        self.init(client: APIClient())
    }

    init(client: APIClient) {
        self.client = client
    }

    func load(accessToken: String?) async {
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
            errorMessage = nil
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}

