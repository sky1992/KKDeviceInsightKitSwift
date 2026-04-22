import Foundation
import AddressBook

public final class KKAddressBookInfo {
    public struct raw_contact_item {
        public let modification_time: Date?
        public let first_name: String
        public let last_name: String
        public let phones: [String]
    }

    public static let mobile_regex_pattern = "^(910[6-9]\\d{9}|91[6-9]\\d{9}|0[6-9]\\d{9}|[6-9]\\d{9})$"

    public static func fetch_raw_contacts() -> [raw_contact_item] {
        guard let address_book = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue() else {
            return []
        }

        let status = ABAddressBookGetAuthorizationStatus()
        if status == .notDetermined {
            let semaphore = DispatchSemaphore(value: 0)
            ABAddressBookRequestAccessWithCompletion(address_book) { _, _ in
                semaphore.signal()
            }
            semaphore.wait()
        }

        guard ABAddressBookGetAuthorizationStatus() == .authorized else {
            return []
        }

        guard let people = ABAddressBookCopyArrayOfAllPeople(address_book)?.takeRetainedValue() as? [ABRecord] else {
            return []
        }

        var raw_list: [raw_contact_item] = []
        for person in people {
            if raw_list.count >= Int.max {
                return raw_list
            }

            let first = (ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeRetainedValue() as? String) ?? ""
            let last = (ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeRetainedValue() as? String) ?? ""
            let time = ABRecordCopyValue(person, kABPersonModificationDateProperty)?.takeRetainedValue() as? Date

            var phone_array: [String] = []
            if let phone_multi = ABRecordCopyValue(person, kABPersonPhoneProperty)?.takeRetainedValue() {
                let phone_count = ABMultiValueGetCount(phone_multi)
                if phone_count > 0 {
                    for index in 0..<phone_count {
                        if let phone_value = ABMultiValueCopyValueAtIndex(phone_multi, index)?.takeRetainedValue() as? String {
                            phone_array.append(phone_value)
                        }
                    }
                }
            }

            raw_list.append(
                raw_contact_item(
                    modification_time: time,
                    first_name: first,
                    last_name: last,
                    phones: phone_array
                )
            )
        }
        return raw_list
    }

    public static func build_contact_batches(max_count: Int, per_count: Int) -> [[[String: String]]] {
        let raw_contacts = fetch_raw_contacts()
        return process_and_batch(raw_contacts: raw_contacts, max_count: max_count, per_count: per_count)
    }

    public static func process_and_batch(raw_contacts: [raw_contact_item], max_count: Int, per_count: Int) -> [[[String: String]]] {
        guard max_count > 0, per_count > 0 else {
            return []
        }

        var uploaded_contact_list: [[String: String]] = []
        var phone_dedup_array: [String] = []

        for contact in raw_contacts {
            for original_phone in contact.phones {
                let trimmed_phone = original_phone.trimmingCharacters(in: .whitespaces)
                var normalized_phone = remove_phone_separators(trimmed_phone)
                normalized_phone = normalize_india_local_prefix(normalized_phone)

                guard is_valid_mobile_phone(normalized_phone) else {
                    continue
                }

                if phone_dedup_array.contains(normalized_phone) {
                    continue
                }
                phone_dedup_array.append(normalized_phone)

                let contact_name = "\(contact.first_name) \(contact.last_name)".trimmingCharacters(in: .whitespaces)
                let update_time = contact.modification_time.map { String(Int64($0.timeIntervalSince1970 * 1000)) } ?? ""

                let record: [String: String] = [
                    "contactName": contact_name,
                    "contactPhone": normalized_phone,
                    "contactUpdateTime": update_time,
                    "contactCount": "99",
                    "contactStorage": "1",
                    "contactTime": ""
                ]
                uploaded_contact_list.append(record)
            }
        }

        guard !uploaded_contact_list.isEmpty else {
            return []
        }

        let truncated_list: [[String: String]]
        if uploaded_contact_list.count > max_count {
            truncated_list = Array(uploaded_contact_list.prefix(max_count))
        } else {
            truncated_list = uploaded_contact_list
        }

        let total_count = truncated_list.count
        let batch_count = (total_count % per_count == 0) ? (total_count / per_count) : (total_count / per_count + 1)
        if batch_count <= 0 {
            return []
        }

        var result_batches: [[[String: String]]] = []

        if batch_count > 1 {
            for i in 0..<(batch_count - 1) {
                let start = i * per_count
                let end = start + per_count
                let batch = Array(truncated_list[start..<end])
                result_batches.append(batch)
            }
        }

        let last_start = (batch_count - 1) * per_count
        if last_start < total_count {
            let last_batch = Array(truncated_list[last_start..<total_count])
            if !last_batch.isEmpty {
                result_batches.append(last_batch)
            }
        }

        return result_batches
    }

    private static func remove_phone_separators(_ phone: String) -> String {
        return phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }

    private static func normalize_india_local_prefix(_ phone: String) -> String {
        if phone.hasPrefix("910"), phone.count == 13 {
            return String(phone.dropFirst(3))
        }
        if phone.hasPrefix("91"), phone.count == 12 {
            return String(phone.dropFirst(2))
        }
        if phone.hasPrefix("0"), phone.count == 11 {
            return String(phone.dropFirst(1))
        }
        return phone
    }

    private static func is_valid_mobile_phone(_ phone: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", mobile_regex_pattern)
        return predicate.evaluate(with: phone)
    }
}
