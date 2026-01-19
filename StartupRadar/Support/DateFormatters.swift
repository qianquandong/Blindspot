import Foundation

enum DateFormatters {
    static let yyyyMMddUTC: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}

extension Date {
    func yyyyMMddUTCString() -> String {
        DateFormatters.yyyyMMddUTC.string(from: self)
    }
}

