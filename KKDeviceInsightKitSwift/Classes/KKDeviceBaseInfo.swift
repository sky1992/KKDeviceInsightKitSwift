import Foundation

public final class KKDeviceBaseInfo {
    public static var number_random: String {
        let disneychars = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<16).compactMap { _ in disneychars.randomElement() })
    }

    public static let number_processors: String = {
        return String(ProcessInfo.processInfo.processorCount)
    }()

    public static var language: String = {
        let languageArray: [String] = NSLocale.preferredLanguages
        guard let language = languageArray.first else {
            return "null"
        }
        return language.components(separatedBy: "-").first ?? "null"
    }()
}
