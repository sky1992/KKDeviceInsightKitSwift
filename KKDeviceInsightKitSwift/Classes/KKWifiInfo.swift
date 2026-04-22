import Foundation
import CoreTelephony
import Network
import SystemConfiguration.CaptiveNetwork
import CFNetwork

public final class KKWifiInfo {
    public static var wifi_name: String {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return "null"
        }

        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] else {
                continue
            }

            if let ssid = interfaceInfo["SSID"] as? String {
                return ssid
            }
        }

        return "null"
    }

    public static var wifi_bssid: String {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return "null"
        }

        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] else {
                continue
            }

            if let bssid = interfaceInfo["BSSID"] as? String {
                return bssid
            }
        }

        return "null"
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

    public static var network_type: String {
        var net = "0"
        let nw = NWPathMonitor()
        let semaphore = DispatchSemaphore(value: 0)

        nw.pathUpdateHandler = { path in
            if path.usesInterfaceType(.wifi) {
                net = "1"
            } else if path.usesInterfaceType(.cellular) {
                net = network_info()
            } else {
                net = "0"
            }
            semaphore.signal()
            nw.cancel()
        }

        nw.start(queue: DispatchQueue.global())
        _ = semaphore.wait(timeout: .now() + 1.5)
        return net
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
