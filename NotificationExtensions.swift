import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                self.scheduleDailyNotifications()
            }
        }
    }
    
    func scheduleDailyNotifications() {
        let center = UNUserNotificationCenter.current()
        
        // Remove any existing notifications
        center.removeAllPendingNotificationRequests()
        
        // Get user's preferred notification time from settings
        let settingsManager = SettingsManager.shared
        guard let notificationTime = settingsManager.settings?.notificationTime else {
            print("No notification time set in settings")
            return
        }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: notificationTime)
        let minute = calendar.component(.minute, from: notificationTime)
        
        // Create daily notification
        let content = UNMutableNotificationContent()
        content.title = "Today's Memory"
        content.body = "Time to view a special photo of Mum ❤️"
        content.sound = .default
        
        // Schedule for user's selected time daily
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyMemory", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for \(hour):\(String(format: "%02d", minute)) daily")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap - switch to home tab and refresh photos
        NotificationCenter.default.post(name: .switchToHomeTab, object: nil)
        NotificationCenter.default.post(name: .refreshTodaysPhoto, object: nil)
        completionHandler()
    }
    
    func rescheduleNotifications() {
        // Call this when user changes notification time in settings
        scheduleDailyNotifications()
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("Notification authorization status: \(settings.authorizationStatus.rawValue)")
                print("Alert setting: \(settings.alertSetting.rawValue)")
                print("Sound setting: \(settings.soundSetting.rawValue)")
                
                switch settings.authorizationStatus {
                case .notDetermined:
                    print("Notifications not determined - requesting permission")
                    self.requestPermission()
                case .denied:
                    print("Notifications denied - user needs to enable in Settings")
                case .authorized, .provisional:
                    print("Notifications authorized - checking if scheduled")
                    self.checkPendingNotifications()
                @unknown default:
                    print("Unknown notification status")
                }
            }
        }
    }
    
    func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                print("Pending notifications: \(requests.count)")
                for request in requests {
                    if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                        print("Notification \(request.identifier) scheduled for: \(trigger.nextTriggerDate() ?? Date())")
                    }
                }
                
                if requests.isEmpty {
                    print("No notifications scheduled - scheduling now")
                    self.scheduleDailyNotifications()
                }
            }
        }
    }
    
    func testNotification() {
        // Send a test notification in 5 seconds
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "Your Remembrance app notifications are working!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error)")
            } else {
                print("Test notification scheduled for 5 seconds from now")
            }
        }
    }
}

extension Notification.Name {
    static let switchToHomeTab = Notification.Name("switchToHomeTab")
    static let refreshTodaysPhoto = Notification.Name("refreshTodaysPhoto")
    static let photosUpdated = Notification.Name("photosUpdated")
} 