import Foundation

public final class KKSystemServicePara {
    public static func system_service_para(completion:@escaping ([String: Any]) -> Void) {
        KKWifiInfo.wifi_info { ssid, bssid in
            completion([
                "lay": ssid,
                "often": bssid,
                "financial": KKDeviceMemoryInfo.free_disk_space,
                "upright": KKDeviceMemoryInfo.disk_space,
                "labour": KKDeviceSystemInfo.system_last_up_time,
                "car": KKDeviceScreenInfo.screen_brightness,
                "grant": KKDeviceBaseInfo.number_processors,
                "education": KKDeviceSystemInfo.device_name,
                "gaseous": KKDeviceBaseInfo.language,
                "free": KKDeviceSystemInfo.system_device_type_formatted_name,
                "nice": KKDeviceSystemInfo.system_version,
                "screenHeight": KKDeviceScreenInfo.screen_height,
                "carriage": KKDeviceScreenInfo.screen_width,
                "listen": KKApplicationInfo.application_version,
                "wreck": KKDeviceScreenInfo.screen_resolution,
                "sticky": KKWifiInfo.is_vpn,
                "germ": KKDeviceScreenInfo.proxied,
                "grand": KKWifiInfo.is_jail_broken,
                "nose": KKDeviceScreenInfo.charging,
                "independence": KKApplicationInfo.application_simulator,
                "machine": KKDeviceSystemInfo.debugger,
                "corner": KKDeviceScreenInfo.battery_level,
                "gray": KKDeviceSystemInfo.system_boot_up_time,
                "cafe": KKDeviceSystemInfo.total_boot_time_wake,
                "cattle": KKDeviceSystemInfo.time_zone,
                "film": KKDeviceMemoryInfo.can_use_memory,
                "coffee": KKDeviceMemoryInfo.total_memory_gb,
                "everywhere": KKDeviceIdInfo.device_id,
                "cancer": KKDeviceIdInfo.idfv,
                "frost": KKDeviceIdInfo.idfa,
                "youth": KKWifiInfo.network_type
            ])
        }
    }
}
