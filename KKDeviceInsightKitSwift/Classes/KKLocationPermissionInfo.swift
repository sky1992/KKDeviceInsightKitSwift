import Foundation
import CoreLocation

public final class KKLocationPermissionInfo {
    private static let location_manager = CLLocationManager()
    private static let location_delegate = location_request_delegate()

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

    public static var location_permission: permission_result {
        let auth = CLLocationManager.authorizationStatus()
        switch auth {
        case .notDetermined:
            guard !Thread.isMainThread else {
                request_location_permission { _ in }
                return permission_result(status: .denied, is_first_system_choice: true)
            }
            var requested_result = permission_result(status: .denied, is_first_system_choice: true)
            let semaphore = DispatchSemaphore(value: 0)
            request_location_permission { result in
                requested_result = result
                semaphore.signal()
            }
            semaphore.wait()
            return requested_result
        case .authorizedAlways:
            return permission_result(status: .allowed, is_first_system_choice: false)
        case .authorizedWhenInUse:
            return permission_result(status: .allowed, is_first_system_choice: false)
        case .denied:
            return permission_result(status: .denied, is_first_system_choice: false)
        case .restricted:
            return permission_result(status: .denied, is_first_system_choice: false)
        @unknown default:
            return permission_result(status: .denied, is_first_system_choice: false)
        }
    }

    public static func request_location_permission(completion: @escaping (permission_result) -> Void) {
        let current = CLLocationManager.authorizationStatus()
        guard current == .notDetermined else {
            completion(location_permission)
            return
        }
        DispatchQueue.main.async {
            location_manager.delegate = location_delegate
            location_delegate.completion = completion
            location_manager.requestWhenInUseAuthorization()
        }
    }

    public static func request_location_coordinate_string(completion: @escaping (_ permission: permission_result, _ latitude: String, _ longitude: String) -> Void) {
        let auth = CLLocationManager.authorizationStatus()
        switch auth {
        case .authorizedAlways, .authorizedWhenInUse:
            DispatchQueue.main.async {
                location_manager.delegate = location_delegate
                location_delegate.prepare_coordinate_completion(completion)
                location_manager.requestLocation()
            }
        case .notDetermined:
            request_location_permission { result in
                guard result.status == .allowed else {
                    completion(result, "", "")
                    return
                }
                DispatchQueue.main.async {
                    location_manager.delegate = location_delegate
                    location_delegate.prepare_coordinate_completion(completion)
                    location_manager.requestLocation()
                }
            }
        case .denied, .restricted:
            completion(location_permission, "", "")
        @unknown default:
            completion(location_permission, "", "")
        }
    }
}

private final class location_request_delegate: NSObject, CLLocationManagerDelegate {
    var completion: ((KKLocationPermissionInfo.permission_result) -> Void)?
    private var coordinate_completion: ((_ permission: KKLocationPermissionInfo.permission_result, _ latitude: String, _ longitude: String) -> Void)?
    private var has_returned_coordinate = false
    private let coordinate_lock = NSLock()

    func prepare_coordinate_completion(_ completion: @escaping (_ permission: KKLocationPermissionInfo.permission_result, _ latitude: String, _ longitude: String) -> Void) {
        coordinate_lock.lock()
        coordinate_completion = completion
        has_returned_coordinate = false
        coordinate_lock.unlock()
    }

    private func finish_coordinate_once(latitude: String, longitude: String) {
        coordinate_lock.lock()
        guard !has_returned_coordinate else {
            coordinate_lock.unlock()
            return
        }
        has_returned_coordinate = true
        let callback = coordinate_completion
        coordinate_completion = nil
        coordinate_lock.unlock()
        callback?(KKLocationPermissionInfo.location_permission, latitude, longitude)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let auth = CLLocationManager.authorizationStatus()
        guard auth != .notDetermined else {
            return
        }
        let callback = completion
        completion = nil
        callback?(KKLocationPermissionInfo.location_permission)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            finish_coordinate_once(latitude: "", longitude: "")
            return
        }
        let latitude = String(format: "%.6f", location.coordinate.latitude)
        let longitude = String(format: "%.6f", location.coordinate.longitude)
        finish_coordinate_once(latitude: latitude, longitude: longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish_coordinate_once(latitude: "", longitude: "")
    }
}
