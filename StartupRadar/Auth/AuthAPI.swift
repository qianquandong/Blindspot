import Foundation

struct AppleTokenExchangeRequest: Codable {
    let identityToken: String
}

struct AuthTokenResponse: Codable {
    let accessToken: String
}

final class AuthAPI {
    private let client: APIClient

    convenience init() {
        self.init(client: APIClient())
    }

    init(client: APIClient) {
        self.client = client
    }

    /// 通过 Apple identityToken 换取后端 accessToken
    func exchangeAppleIdentityToken(_ identityToken: String) async throws -> String {
        let payload = AppleTokenExchangeRequest(identityToken: identityToken)
        let body = try JSONCoders.encoder().encode(payload)

        // TODO: 若你的后端路径不同，请改这里
        let resp: AuthTokenResponse = try await client.request(
            "/auth/apple",
            method: "POST",
            accessToken: nil,
            body: body
        )
        return resp.accessToken
    }
}

