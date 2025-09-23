import Foundation
import SwiftUI

class SimpleSettingsManager: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("notificationHour") var notificationHour: Int = 9
    @AppStorage("notificationMinute") var notificationMinute: Int = 0
    @AppStorage("isNotificationsEnabled") var isNotificationsEnabled: Bool = false
    @AppStorage("startDate") var startDateString: String = ""

    var startDate: Date? {
        get {
            if startDateString.isEmpty { return nil }
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: startDateString)
        }
        set {
            if let date = newValue {
                let formatter = ISO8601DateFormatter()
                startDateString = formatter.string(from: date)
            } else {
                startDateString = ""
            }
        }
    }

    func updateNotificationTime(_ date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        notificationHour = components.hour ?? 9
        notificationMinute = components.minute ?? 0
    }

    func getNotificationTime() -> Date {
        Calendar.current.date(bySettingHour: notificationHour, minute: notificationMinute, second: 0, of: Date()) ?? Date()
    }
}