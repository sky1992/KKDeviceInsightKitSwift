import Foundation
import CoreTelephony
import NetworkExtension


public final class KKWifiInfo {
    
    public static func wifi_info(completion: @escaping (String, String, String) -> Void) {
        NEHotspotNetwork.fetchCurrent { network in
            let ssid = network?.ssid ?? "null"
            let bssid = network?.bssid ?? "null"
            var net = "0"
            if ssid != "null" {
                net = "1"
            } else {
                net = network_info()
            }
            completion(ssid, bssid, net)
        }
    }

    public static var is_vpn: String {
        let vpnInterfaces = ["tap", "tun", "ppp", "ipsec", "utun"]

        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() else {
            return "false"
        }
        let scopedKey = "__SCOPED__" as CFString
        guard let scopedSettings = CFDictionaryGetValue(proxySettings, Unmanaged.passUnretained(scopedKey).toOpaque()) else {
            return "false"
        }

        let scopedDict = Unmanaged<NSDictionary>.fromOpaque(scopedSettings).takeUnretainedValue()
        var isConnected = false

        for key in scopedDict.allKeys {
            guard let interfaceKey = key as? String else { continue }

            let lowercaseKey = interfaceKey.lowercased()
            for prefix in vpnInterfaces {
                if lowercaseKey.hasPrefix(prefix) {
                    isConnected = true
                    break
                }
            }
            if isConnected { break }
        }

        return isConnected ? "true" : "false"
    }

    static func network_info() -> String {
        guard let logy = CTTelephonyNetworkInfo().serviceCurrentRadioAccessTechnology?.values.first else {
            return "0"
        }
        switch logy {
        case CTRadioAccessTechnologyNRNSA, CTRadioAccessTechnologyNR:
            return "5"
        case CTRadioAccessTechnologyLTE:
            return "4"
        case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA:
            return "3"
        case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge:
            return "2"
        default:
            return "0"
        }
    }

    public static let is_jail_broken: String = {
        let cydiaPath = "/Applications/Cydia.app"
        let aptPath = "/private/var/lib/apt/"
        let jailBroken = [cydiaPath, aptPath].map({ FileManager.default.fileExists(atPath: $0) }).contains(true)
        return jailBroken ? "true" : "false"
    }()
}
