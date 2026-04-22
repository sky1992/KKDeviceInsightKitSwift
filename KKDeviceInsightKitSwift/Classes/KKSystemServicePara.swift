import Foundation

public final class KKSystemServicePara {
    public static var system_service_para: [String: Any] = [
        "wifiName": KKWifiInfo.wifi_name,
        "wifiBssid": KKWifiInfo.wifi_bssid,
        "cashCanUse": KKDeviceMemoryInfo.free_disk_space,
        "cashTotal": KKDeviceMemoryInfo.disk_space,
        "lastBootTime": KKDeviceSystemInfo.system_last_up_time,
        "screenBrightness": KKDeviceScreenInfo.screen_brightness,
        "cpuNum": KKDeviceBaseInfo.number_processors,
        "phoneMark": KKDeviceSystemInfo.device_name,
        "defaultLanguage": KKDeviceBaseInfo.language,
        "phoneType": KKDeviceSystemInfo.system_device_type_formatted_name,
        "systemVersions": KKDeviceSystemInfo.system_version,
        "screenHeight": KKDeviceScreenInfo.screen_height,
        "screenWidth": KKDeviceScreenInfo.screen_width,
        "versionCode": KKApplicationInfo.application_version,
        "screenResolution": KKDeviceScreenInfo.screen_resolution,
        "isvpn": KKWifiInfo.is_vpn,
        "proxied": KKDeviceScreenInfo.proxied,
        "rooted": KKWifiInfo.is_jail_broken,
        "charged": KKDeviceScreenInfo.charging,
        "simulated": KKApplicationInfo.application_simulator,
        "debugged": KKDeviceSystemInfo.debugger,
        "batteryLevel": KKDeviceScreenInfo.battery_level,
        "totalBootTime": KKDeviceSystemInfo.system_boot_up_time,
        "totalBootTimeWake": KKDeviceSystemInfo.total_boot_time_wake,
        "defaultTimeZone": KKDeviceSystemInfo.time_zone,
        "ramCanUse": KKDeviceMemoryInfo.can_use_memory,
        "ramTotal": KKDeviceMemoryInfo.total_memory_gb,
        "uuid": KKDeviceIdInfo.device_id,
        "idfv": KKDeviceIdInfo.idfv,
        "idfa": KKDeviceIdInfo.idfa,
        "network": KKWifiInfo.network_type
    ]
}
