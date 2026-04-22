import Foundation
import UIKit
import Security
import AdSupport
import AppTrackingTransparency

public final class KKDeviceIdInfo {
    public static var device_id: String {
        let disneykey = String(
            format: "%@.id.some.app",
            Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? "unknown.bundle"
        )
        if let disneyid = fetch_device_id(for_key: disneykey) {
            return disneyid
        } else {
            let disneyid = UIDevice.current.identifierForVendor?.uuidString
                ?? (CFUUIDCreateString(kCFAllocatorDefault, CFUUIDCreate(kCFAllocatorDefault)) as String? ?? "null")
            save_device_id(disneyid, for_key: disneykey)
            return disneyid
        }
    }

    static func save_device_id(_ ref: String, for_key diskey: String) {
        var ksec: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: diskey,
            kSecAttrAccount as String: diskey,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(ksec as CFDictionary)
        guard let data = ref.data(using: .utf8) else {
            return
        }
        ksec[kSecValueData as String] = data
        SecItemAdd(ksec as CFDictionary, nil)
    }

    static func fetch_device_id(for_key diskey: String) -> String? {
        let kSec: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: diskey,
            kSecAttrAccount as String: diskey,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var obj: CFTypeRef?
        guard SecItemCopyMatching(kSec as CFDictionary, &obj) == errSecSuccess,
              let objData = obj as? Data,
              let ref = String(data: objData, encoding: .utf8) else {
            return nil
        }
        return ref
    }

    public static var idfa: String {
        var idfa: String = "null"
        ATTrackingManager.requestTrackingAuthorization { status in
            if status == .authorized {
                idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            }
        }
        return idfa
    }

    public static var idfv: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "null"
    }
}
