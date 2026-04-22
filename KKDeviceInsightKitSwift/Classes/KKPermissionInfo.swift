import Foundation
import Contacts
import AVFoundation
import UserNotifications

public final class KKPermissionInfo {
    public enum permission_status: String {
        case allowed
        case denied
        case limited
    }

    public struct permission_result {
        public let status: permission_status
        public let is_first_system_choice: Bool

        public var as_dictionary: [String: Any] {
            return [
                "status": status.rawValue,
                "is_first_system_choice": is_first_system_choice
            ]
        }
    }

    public static var contacts_permission: permission_result {
        let auth = CNContactStore.authorizationStatus(for: .contacts)
        switch auth {
        case .notDetermined:
            guard !Thread.isMainThread else {
                request_contacts_permission { _ in }
                return permission_result(status: .denied, is_first_system_choice: true)
            }
            var requested_result = permission_result(status: .denied, is_first_system_choice: true)
            let semaphore = DispatchSemaphore(value: 0)
            request_contacts_permission { result in
                requested_result = result
                semaphore.signal()
            }
            semaphore.wait()
            return requested_result
        case .authorized:
            return permission_result(status: .allowed, is_first_system_choice: false)
        case .denied:
            return permission_result(status: .denied, is_first_system_choice: false)
        case .restricted:
            return permission_result(status: .denied, is_first_system_choice: false)
        case .limited:
            return permission_result(status: .limited, is_first_system_choice: false)
        @unknown default:
            return permission_result(status: .denied, is_first_system_choice: false)
        }
    }

    public static var camera_permission: permission_result {
        let auth = AVCaptureDevice.authorizationStatus(for: .video)
        switch auth {
        case .notDetermined:
            guard !Thread.isMainThread else {
                request_camera_permission { _ in }
                return permission_result(status: .denied, is_first_system_choice: true)
            }
            var requested_result = permission_result(status: .denied, is_first_system_choice: true)
            let semaphore = DispatchSemaphore(value: 0)
            request_camera_permission { result in
                requested_result = result
                semaphore.signal()
            }
            semaphore.wait()
            return requested_result
        case .authorized:
            return permission_result(status: .allowed, is_first_system_choice: false)
        case .denied:
            return permission_result(status: .denied, is_first_system_choice: false)
        case .restricted:
            return permission_result(status: .denied, is_first_system_choice: false)
        @unknown default:
            return permission_result(status: .denied, is_first_system_choice: false)
        }
    }

    public static func notification_permission(completion: @escaping (permission_result) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let result: permission_result
            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
                    let request_result = permission_result(
                        status: granted ? .allowed : .denied,
                        is_first_system_choice: true
                    )
                    completion(request_result)
                }
                return
            case .authorized:
                result = permission_result(status: .allowed, is_first_system_choice: false)
            case .denied:
                result = permission_result(status: .denied, is_first_system_choice: false)
            case .provisional:
                result = permission_result(status: .limited, is_first_system_choice: false)
            case .ephemeral:
                result = permission_result(status: .limited, is_first_system_choice: false)
            @unknown default:
                result = permission_result(status: .denied, is_first_system_choice: false)
            }
            completion(result)
        }
    }

    public static func request_contacts_permission(completion: @escaping (permission_result) -> Void) {
        let auth = CNContactStore.authorizationStatus(for: .contacts)
        guard auth == .notDetermined else {
            completion(contacts_permission)
            return
        }
        CNContactStore().requestAccess(for: .contacts) { _, _ in
            completion(contacts_permission)
        }
    }

    public static func request_camera_permission(completion: @escaping (permission_result) -> Void) {
        let auth = AVCaptureDevice.authorizationStatus(for: .video)
        guard auth == .notDetermined else {
            completion(camera_permission)
            return
        }
        AVCaptureDevice.requestAccess(for: .video) { _ in
            completion(camera_permission)
        }
    }
}
