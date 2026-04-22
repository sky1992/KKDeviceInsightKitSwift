import Foundation
import Darwin
import MachO

public final class KKDeviceMemoryInfo {
    private static let total_bytes = Double(ProcessInfo.processInfo.physicalMemory)

    // MB
    public static var total_memory: Double = {
        let allMemory = Double(ProcessInfo.processInfo.physicalMemory)
        var totalMemory: Double = 0.00
        totalMemory = (allMemory / 1024.0) / 1024.0
        let toNearest: Int = 256
        let remainder: Int = Int(totalMemory) % toNearest
        if remainder >= toNearest / 2 {
            totalMemory = Double((Int(totalMemory) - remainder) + 256)
        } else {
            totalMemory = Double(Int(totalMemory) - remainder)
        }
        if totalMemory <= 0 {
            return -1
        }

        return totalMemory
    }()

    // GB
    public static var total_memory_gb: String = {
        return String(format: "%.6f", total_memory / 1024.0)
    }()

    public static var can_use_memory: String = {
        let totalMemoryGB = total_bytes / (1024.0 * 1024.0 * 1024.0)

        var pageSize: vm_size_t = 0
        var vmStats = vm_statistics64_data_t()
        var infoCount = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<Int32>.size)

        if host_page_size(mach_host_self(), &pageSize) != KERN_SUCCESS {
            return "-1"
        }

        let result = withUnsafeMutablePointer(to: &vmStats) { vmStatsPtr in
            return vmStatsPtr.withMemoryRebound(to: Int32.self, capacity: MemoryLayout<vm_statistics64_data_t>.size) { reboundPtr in
                return host_statistics64(
                    mach_host_self(),
                    HOST_VM_INFO64,
                    host_info64_t(reboundPtr),
                    &infoCount
                )
            }
        }

        if result != KERN_SUCCESS {
            return "-1"
        }

        let usedMemory = Double(vmStats.active_count +
                                vmStats.inactive_count +
                                vmStats.wire_count) * Double(pageSize)

        return String(format: "%.6f", max(0.0, totalMemoryGB - usedMemory / (1024.0 * 1024.0 * 1024.0)))
    }()

    public static var disk_space: String = {
        let space = long_disk_space()
        guard space > 0 else {
            return "0"
        }
        let diskSpace = format_memory(space)
        guard !diskSpace.isEmpty else {
            return "0"
        }
        return diskSpace
    }()

    static func long_disk_space() -> Int64 {
        var diskSpace: Int64 = 0
        let fileManager = FileManager.default
        let homeDirectory = NSHomeDirectory()
        do {
            let fileAttributes = try fileManager.attributesOfFileSystem(forPath: homeDirectory)

            if let systemSize = fileAttributes[.systemSize] as? NSNumber {
                diskSpace = systemSize.int64Value
            } else {
                return -1
            }
        } catch {
            return -1
        }
        if diskSpace <= 0 {
            return -1
        }
        return diskSpace
    }

    public static var free_disk_space: String = {
        let space = long_free_disk_space()
        guard space > 0 else {
            return "0"
        }
        let diskSpace = format_memory(space)
        guard !diskSpace.isEmpty else {
            return "0"
        }
        return diskSpace
    }()

    static func long_free_disk_space() -> Int64 {
        var freeDiskSpace: Int64 = 0

        let fileManager = FileManager.default
        let homeDirectory = NSHomeDirectory()

        do {
            let attributes = try fileManager.attributesOfFileSystem(forPath: homeDirectory)
            if let freeSize = attributes[.systemFreeSize] as? NSNumber {
                freeDiskSpace = freeSize.int64Value
            } else {
                return -1
            }
            guard freeDiskSpace > 0 else {
                return -1
            }
            return freeDiskSpace
        } catch {
            return -1
        }
    }

    static func format_memory(_ space: Int64) -> String {
        var formattedBytes: String?

        let numberBytes = Double(space)
        let totalGB = numberBytes / 1024 / 1024 / 1024

        formattedBytes = String(format: "%.6f", totalGB)
        
        guard let result = formattedBytes, !result.isEmpty else {
            return "0"
        }
        return result
    }

    static func formatted_memory(_ space: UInt64) -> String? {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,###,###,###"

        let theNumber = NSNumber(value: space)
        let formattedBytes = formatter.string(from: theNumber)

        guard let result = formattedBytes, !result.isEmpty else {
            return nil
        }

        return result
    }
}
