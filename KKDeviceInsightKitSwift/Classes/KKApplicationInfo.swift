import Foundation
import UIKit

public final class KKApplicationInfo {
    public static let application_version: String = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        return version
    }()

    public static let application_simulator: String = {
        if application_version.contains("Simulator") {
            return "true"
        }
        return "false"
    }()
}
