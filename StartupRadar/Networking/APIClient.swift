import Foundation

final class APIClient {
    private let baseURL: URL
    private let urlSession: URLSession
    private let cache: ResponseCache

    init(baseURL: URL = AppConfig.apiBaseURL, urlSession: URLSession = .shared, cache: ResponseCache = ResponseCache()) {
        self.baseURL = baseURL
        self.urlSession = urlSession
        self.cache = cache
    }

    func request<T: Decodable>(
        _ path: String,
        method: String = "GET",
        accessToken: String?,
        queryItems: [URLQueryItem] = [],
        body: Data? = nil
    ) async throws -> T {
        if AppConfig.isMockMode {
            let data = try MockServer.responseData(path: path, method: method, queryItems: queryItems, body: body)
            do {
                return try JSONCoders.decoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error.localizedDescription)
            }
        }

        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.httpBody = body
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let accessToken, !accessToken.isEmpty {
            req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        let cacheKey = "\(method) \(url.absoluteString) body=\(body.map { String(data: $0, encoding: .utf8) ?? "" } ?? "")"

        do {
            let (data, resp) = try await urlSession.data(for: req)
            let http = resp as? HTTPURLResponse
            let status = http?.statusCode ?? -1

            if status == 401 { throw APIError.unauthorized }
            guard (200...299).contains(status) else {
                let bodyStr = String(data: data, encoding: .utf8)
                throw APIError.httpError(statusCode: status, body: bodyStr)
            }

            cache.write(data, key: cacheKey)
            do {
                return try JSONCoders.decoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error.localizedDescription)
            }
        } catch let err as APIError {
            // 非 401 时允许回退缓存（提升可用性）
            if case .unauthorized = err {
                throw err
            }
            if let cached = cache.read(key: cacheKey),
               let decoded = try? JSONCoders.decoder().decode(T.self, from: cached) {
                return decoded
            }
            throw err
        } catch {
            if let cached = cache.read(key: cacheKey),
               let decoded = try? JSONCoders.decoder().decode(T.self, from: cached) {
                return decoded
            }
            throw APIError.transportError(error.localizedDescription)
        }
    }
}

