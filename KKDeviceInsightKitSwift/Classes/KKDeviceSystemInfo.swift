import Foundation
import UIKit
import Darwin

public final class KKDeviceSystemInfo {
    public static var debugger: String {
        var mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.size

        info.kp_proc.p_flag = 0

        let ret = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)

        if ret != 0 {
            return "false"
        }
        if (info.kp_proc.p_flag & P_TRACED) != 0 {
            return "true"
        }
        return "false"
    }

    public static var time_zone: String {
        return TimeZone.current.identifier
    }

    public static var total_boot_time_wake: String {
        return String(Int(ProcessInfo.processInfo.systemUptime * 1000))
    }

    public static var process_system_up_time: TimeInterval {
        return ProcessInfo.processInfo.systemUptime
    }

    public static func system_uptime(units_style: DateComponentsFormatter.UnitsStyle) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = units_style
        return formatter.string(from: process_system_up_time)
    }

    public static var system_boot_up_time: String {
        var boottime = timeval()
        var size = MemoryLayout<timeval>.size
        var mib = [CTL_KERN, KERN_BOOTTIME]

        if sysctl(&mib, 2, &boottime, &size, nil, 0) == -1 || boottime.tv_sec == 0 {
            return "-1"
        }

        var now = timeval()
        gettimeofday(&now, nil)

        var uptime = Int64(now.tv_sec - boottime.tv_sec) * 1000
        uptime += Int64(now.tv_usec - boottime.tv_usec) / 1000

        return String(Int64(uptime))
    }

    public static var system_last_up_time: String {
        let uptime = Int64(system_boot_up_time) ?? -1
        guard uptime != -1 else {
            return "-1"
        }
        let interval = TimeInterval(uptime) / 1000.0
        let bootDate = Date(timeIntervalSinceNow: -interval)
        let timestamp = Int64(bootDate.timeIntervalSince1970 * 1000)

        return String(timestamp)
    }

    public static var system_current_time: String {
        return String(Int64(Date().timeIntervalSince1970 * 1000))
    }

    public static var system_name: String {
        let device: UIDevice = .current
        return device.systemName
    }

    public static var device_name: String {
        let device: UIDevice = .current
        return device.name
    }

    public static var system_version: String {
        let device: UIDevice = .current
        return device.systemVersion
    }

    public static var system_device_type: String {
        let device: UIDevice = .current
        return device.system_device_type
    }

    public static var system_device_type_formatted_name: String {
        let name = formatted_name(model_name: system_device_type)
        return name ?? ""
    }

    static func formatted_name(model_name: String) -> String? {
        return device_model_list.first(where: { $0["modelName"] == model_name }).map({ ($0["formatted"] ?? "") })
    }

    private static let device_model_list = [
        ["modelName": "i386", "formatted": "iPhone Simulator"],
        ["modelName": "x86_64", "formatted": "iPhone Simulator"],
        ["modelName": "arm64", "formatted": "iPhone Simulator"],
        ["modelName": "iPhone4,1", "formatted": "iPhone 4S"],
        ["modelName": "iPhone4,1", "formatted": "iPhone 4S"],
        ["modelName": "iPhone5,1", "formatted": "iPhone 5"],
        ["modelName": "iPhone5,2", "formatted": "iPhone 5"],
        ["modelName": "iPhone5,3", "formatted": "iPhone 5c"],
        ["modelName": "iPhone5,4", "formatted": "iPhone 5c"],
        ["modelName": "iPhone6,1", "formatted": "iPhone 5s"],
        ["modelName": "iPhone6,2", "formatted": "iPhone 5s"],
        ["modelName": "iPhone7,1", "formatted": "iPhone 6 Plus"],
        ["modelName": "iPhone7,2", "formatted": "iPhone 6"],
        ["modelName": "iPhone8,1", "formatted": "iPhone 6S"],
        ["modelName": "iPhone8,2", "formatted": "iPhone 6S Plus"],
        ["modelName": "iPhone8,4", "formatted": "iPhone SE"],
        ["modelName": "iPhone9,1", "formatted": "iPhone 7"],
        ["modelName": "iPhone9,3", "formatted": "iPhone 7"],
        ["modelName": "iPhone9,2", "formatted": "iPhone 7 Plus"],
        ["modelName": "iPhone9,4", "formatted": "iPhone 7 Plus"],
        ["modelName": "iPhone10,1", "formatted": "iPhone 8"],
        ["modelName": "iPhone10,4", "formatted": "iPhone 8"],
        ["modelName": "iPhone10,2", "formatted": "iPhone 8 Plus"],
        ["modelName": "iPhone10,5", "formatted": "iPhone 8 Plus"],
        ["modelName": "iPhone10,3", "formatted": "iPhone X"],
        ["modelName": "iPhone10,6", "formatted": "iPhone X"],
        ["modelName": "iPhone11,2", "formatted": "iPhone XS"],
        ["modelName": "iPhone11,4", "formatted": "iPhone XS Max"],
        ["modelName": "iPhone11,6", "formatted": "iPhone XS Max"],
        ["modelName": "iPhone11,8", "formatted": "iPhone XR"],
        ["modelName": "iPhone12,1", "formatted": "iPhone 11"],
        ["modelName": "iPhone12,3", "formatted": "iPhone 11 Pro"],
        ["modelName": "iPhone12,5", "formatted": "iPhone 11 Pro Max"],
        ["modelName": "iPhone12,8", "formatted": "iPhone SE"],
        ["modelName": "iPhone13,1", "formatted": "iPhone 12 Mini"],
        ["modelName": "iPhone13,2", "formatted": "iPhone 12"],
        ["modelName": "iPhone13,3", "formatted": "iPhone 12 Pro"],
        ["modelName": "iPhone13,4", "formatted": "iPhone 12 Pro Max"],
        ["modelName": "iPhone14,4", "formatted": "iPhone 13 mini"],
        ["modelName": "iPhone14,5", "formatted": "iPhone 13"],
        ["modelName": "iPhone14,2", "formatted": "iPhone 13 Pro"],
        ["modelName": "iPhone14,3", "formatted": "iPhone 13 Pro Max"],
        ["modelName": "iPhone14,6", "formatted": "iPhone SE 3"],
        ["modelName": "iPhone14,7", "formatted": "iPhone 14"],
        ["modelName": "iPhone14,8", "formatted": "iPhone 14 Plus"],
        ["modelName": "iPhone15,2", "formatted": "iPhone 14 Pro"],
        ["modelName": "iPhone15,3", "formatted": "iPhone 14 Pro Max"],
        ["modelName": "iPhone15,4", "formatted": "iPhone 15"],
        ["modelName": "iPhone15,5", "formatted": "iPhone 15 Plus"],
        ["modelName": "iPhone16,1", "formatted": "iPhone 15 Pro"],
        ["modelName": "iPhone16,2", "formatted": "iPhone 15 Pro Max"],
        ["modelName": "iPhone17,1", "formatted": "iPhone 16 Pro"],
        ["modelName": "iPhone17,2", "formatted": "iPhone 16 Pro Max"],
        ["modelName": "iPhone17,3", "formatted": "iPhone 16"],
        ["modelName": "iPhone17,4", "formatted": "iPhone 16 Plus"],
        ["modelName": "iPhone17,5", "formatted": "iPhone 16e"],
        ["modelName": "iPhone18,1", "formatted": "iPhone 17 Pro"],
        ["modelName": "iPhone18,2", "formatted": "iPhone 17 Pro Max"],
        ["modelName": "iPhone18,3", "formatted": "iPhone 17"],
        ["modelName": "iPhone18,4", "formatted": "iPhone Air"],
        ["modelName": "iPad2,5", "formatted": "iPad Mini"],
        ["modelName": "iPad2,6", "formatted": "iPad Mini"],
        ["modelName": "iPad2,7", "formatted": "iPad Mini"],
        ["modelName": "iPad3,1", "formatted": "iPad 3"],
        ["modelName": "iPad3,2", "formatted": "iPad 3"],
        ["modelName": "iPad3,3", "formatted": "iPad 3"],
        ["modelName": "iPad3,4", "formatted": "iPad 4"],
        ["modelName": "iPad3,5", "formatted": "iPad 4"],
        ["modelName": "iPad3,6", "formatted": "iPad 4"],
        ["modelName": "iPad4,1", "formatted": "iPad AIR"],
        ["modelName": "iPad4,2", "formatted": "iPad AIR"],
        ["modelName": "iPad4,3", "formatted": "iPad AIR"],
        ["modelName": "iPad4,4", "formatted": "iPad Mini 2"],
        ["modelName": "iPad4,5", "formatted": "iPad Mini 2"],
        ["modelName": "iPad4,6", "formatted": "iPad Mini 2"],
        ["modelName": "iPad4,7", "formatted": "iPad Mini 3"],
        ["modelName": "iPad4,8", "formatted": "iPad Mini 3"],
        ["modelName": "iPad4,9", "formatted": "iPad Mini 3"],
        ["modelName": "iPad5,1", "formatted": "iPad Mini 4"],
        ["modelName": "iPad5,2", "formatted": "iPad Mini 4"],
        ["modelName": "iPad5,3", "formatted": "iPad AIR 2"],
        ["modelName": "iPad5,4", "formatted": "iPad AIR 2"],
        ["modelName": "iPad6,3", "formatted": "iPad PRO 9.7"],
        ["modelName": "iPad6,4", "formatted": "iPad PRO 9.7"],
        ["modelName": "iPad6,7", "formatted": "iPad PRO 12.9"],
        ["modelName": "iPad6,8", "formatted": "iPad PRO 12.9"],
        ["modelName": "iPad6,11", "formatted": "iPad (5th generation)"],
        ["modelName": "iPad6,12", "formatted": "iPad (5th generation)"],
        ["modelName": "iPad7,1", "formatted": "iPad PRO 12.9"],
        ["modelName": "iPad7,2", "formatted": "iPad PRO 12.9"],
        ["modelName": "iPad7,3", "formatted": "iPad PRO 10.5"],
        ["modelName": "iPad7,4", "formatted": "iPad PRO 10.5"],
        ["modelName": "iPad7,5", "formatted": "iPad (6th Gen)"],
        ["modelName": "iPad7,6", "formatted": "iPad (6th Gen)"],
        ["modelName": "iPad7,11", "formatted": "iPad (7th Gen)"],
        ["modelName": "iPad7,12", "formatted": "iPad (7th Gen)"],
        ["modelName": "iPad8,1", "formatted": "iPad PRO 11"],
        ["modelName": "iPad8,2", "formatted": "iPad PRO 11"],
        ["modelName": "iPad8,3", "formatted": "iPad PRO 11"],
        ["modelName": "iPad8,4", "formatted": "iPad PRO 11"],
        ["modelName": "iPad8,5", "formatted": "iPad PRO 12.9"],
        ["modelName": "iPad8,6", "formatted": "iPad PRO 12.9"],
        ["modelName": "iPad8,7", "formatted": "iPad PRO 12.9"],
        ["modelName": "iPad8,8", "formatted": "iPad PRO 12.9"],
        ["modelName": "iPad8,9", "formatted": "iPad PRO 11"],
        ["modelName": "iPad8,10", "formatted": "iPad PRO 11"],
        ["modelName": "iPad8,11", "formatted": "iPad PRO 12.9"],
        ["modelName": "iPad8,12", "formatted": "iPad PRO 12.9"],
        ["modelName": "iPad11,1", "formatted": "iPad mini 5th Gen"],
        ["modelName": "iPad11,2", "formatted": "iPad mini 5th Gen"],
        ["modelName": "iPad11,3", "formatted": "iPad Air 3rd Gen"],
        ["modelName": "iPad11,4", "formatted": "iPad Air 3rd Gen"],
        ["modelName": "iPad11,6", "formatted": "iPad 8th Gen"],
        ["modelName": "iPad11,7", "formatted": "iPad 8th Gen"],
        ["modelName": "iPad13,1", "formatted": "iPad air 4th Gen"],
        ["modelName": "iPad13,2", "formatted": "iPad air 4th Gen"]
    ]
}

private extension UIDevice {
    var system_device_type: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        return mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
}
