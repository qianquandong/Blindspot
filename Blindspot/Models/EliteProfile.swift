import Foundation

struct EliteProfile: Codable, Hashable {
    var industryExperience: String
    var skillTags: [String]
    var weeklyHours: Int
    var budgetUSD: Int
    var riskPreference: String
}

enum EliteProfileStore {
    private static let key = "elite_profile_v1"

    static func load() -> EliteProfile? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONCoders.decoder().decode(EliteProfile.self, from: data)
    }

    static func save(_ profile: EliteProfile) {
        let data = try? JSONCoders.encoder().encode(profile)
        UserDefaults.standard.set(data, forKey: key)
    }
}

