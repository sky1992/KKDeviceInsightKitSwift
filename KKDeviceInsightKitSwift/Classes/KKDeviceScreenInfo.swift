import Foundation
import UIKit
import CFNetwork

public final class KKDeviceScreenInfo {
    public static var screen_width: String = {
        return "\(Int(UIScreen.main.bounds.size.width))"
    }()

    public static var screen_height: String = {
        return "\(Int(UIScreen.main.bounds.size.height))"
    }()

    public static var battery_level: String = {
        UIDevice.current.isBatteryMonitoringEnabled = true
        var batteryLevel = 0.0
        let batteryCharge = UIDevice.current.batteryLevel
        if batteryCharge > 0.0 {
            batteryLevel = Double(batteryCharge * 100)
        } else {
            return "-1"
        }
        return String(Int(batteryLevel))
    }()

    public static var charging: String = {
        UIDevice.current.isBatteryMonitoringEnabled = true
        if UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full {
            return "true"
        }
        return "false"
    }()

    public static var screen_resolution: String = {
        return "\(Int(UIScreen.main.bounds.size.width * UIScreen.main.scale))-\(Int(UIScreen.main.bounds.size.height * UIScreen.main.scale))"
    }()

    public static var screen_brightness: String = {
        let brightness = UIScreen.main.brightness
        guard brightness >= 0.0 && brightness <= 1.0 else {
            return "-1"
        }
        return "\(Int(brightness * 100))"
    }()

    public static var proxied: String = {
        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else {
            return "false"
        }
        guard let url = URL(string: "http://www.apple.com") else {
            return "false"
        }
        let proxies = CFNetworkCopyProxiesForURL(url as CFURL, proxySettings as CFDictionary).takeRetainedValue() as? [[String: Any]] ?? []
        if let firstProxy = proxies.first,
           let proxyType = firstProxy[kCFProxyTypeKey as String] as? String,
           proxyType == kCFProxyTypeNone as String {
            return "false"
        } else {
            return "true"
        }
    }()
}
