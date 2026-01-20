import Combine
import Foundation

@MainActor
final class SignalsViewModel: ObservableObject {
    @Published private(set) var signals: [Signal] = []
    @Published private(set) var nextCursor: String?
    @Published private(set) var updatedAt: Date?
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var selectedType: SignalType?
    @Published var industryKeyword: String = ""

    private let client: APIClient
    private let pageSize: Int = 50

    convenience init() {
        self.init(client: APIClient())
    }

    init(client: APIClient) {
        self.client = client
    }

    func loadFirstPage(accessToken: String?) async {
        signals = []
        nextCursor = nil
        await loadMore(accessToken: accessToken, isFirst: true)
    }

    func loadMore(accessToken: String?, isFirst: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        var query: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(pageSize))
        ]
        if let nextCursor, !isFirst {
            query.append(URLQueryItem(name: "cursor", value: nextCursor))
        }
        if let selectedType {
            query.append(URLQueryItem(name: "type", value: selectedType.rawValue))
        }
        if !industryKeyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            query.append(URLQueryItem(name: "industry", value: industryKeyword))
        }

        do {
            // TODO: 若后端路径不同，请改这里
            let page: SignalsPage = try await client.request(
                "/signals",
                accessToken: accessToken,
                queryItems: query
            )
            updatedAt = page.updatedAt
            nextCursor = page.nextCursor
            signals.append(contentsOf: page.items)
            errorMessage = nil
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}

