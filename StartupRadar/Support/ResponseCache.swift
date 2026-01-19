import CryptoKit
import Foundation

final class ResponseCache {
    private let folderURL: URL

    init(folderName: String = "StartupRadarResponseCache") {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        folderURL = caches.appendingPathComponent(folderName, isDirectory: true)
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
    }

    func write(_ data: Data, key: String) {
        let url = fileURL(for: key)
        try? data.write(to: url, options: [.atomic])
    }

    func read(key: String) -> Data? {
        let url = fileURL(for: key)
        return try? Data(contentsOf: url)
    }

    private func fileURL(for key: String) -> URL {
        let digest = SHA256.hash(data: Data(key.utf8))
        let name = digest.compactMap { String(format: "%02x", $0) }.joined()
        return folderURL.appendingPathComponent(name).appendingPathExtension("json")
    }
}

