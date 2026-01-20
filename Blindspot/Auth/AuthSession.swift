import Combine
import Foundation

@MainActor
final class AuthSession: ObservableObject {
    @Published private(set) var accessToken: String?

    var isAuthenticated: Bool {
        accessToken?.isEmpty == false
    }

    private let keychain = KeychainStore()
    private let accessTokenKey = "access_token"

    init() {
        accessToken = keychain.readString(key: accessTokenKey)
    }

    func setAccessToken(_ token: String) {
        accessToken = token
        keychain.saveString(token, key: accessTokenKey)
    }

    func signOut() {
        accessToken = nil
        keychain.delete(key: accessTokenKey)
    }
}

