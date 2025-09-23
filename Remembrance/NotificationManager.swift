import Foundation
import UserNotifications
import SwiftUI

public final class NotificationManager: NSObject, ObservableObject {
    public static let shared = NotificationManager()
    
    @Published public var isNotificationEnabled = false
    @Published public var notificationTime = Date()
    
    private override init() {
        super.init()
        loadSettings()
        setupDelegate()
    }
    
    private func setupDelegate() {
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Permission Management
    
    public func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            
            await MainActor.run {
                self.isNotificationEnabled = granted
                self.saveSettings()
            }
            
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    public func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Daily Reminder Management
    
    public func scheduleDailyReminder(at time: Date) {
        // Cancel existing notifications
        cancelDailyReminder()
        
        guard isNotificationEnabled else {
            print("Notifications not enabled")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Today's Mum Memory"
        content.body = "Take a moment to remember and reflect. Your journey of love continues today."
        content.sound = .default
        content.badge = 1
        
        // Set up daily trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "daily_mum_memory",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.notificationTime = time
                    self.saveSettings()
                }
            }
        }
    }
    
    public func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["daily_mum_memory"]
        )
        print("Daily reminder cancelled")
    }
    
    // MARK: - Settings Persistence
    
    private func saveSettings() {
        UserDefaults.standard.set(isNotificationEnabled, forKey: "notification_enabled")
        UserDefaults.standard.set(notificationTime, forKey: "notification_time")
    }
    
    private func loadSettings() {
        isNotificationEnabled = UserDefaults.standard.bool(forKey: "notification_enabled")
        
        if let savedTime = UserDefaults.standard.object(forKey: "notification_time") as? Date {
            notificationTime = savedTime
        } else {
            // Default to 9:00 AM
            let calendar = Calendar.current
            notificationTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    public func getNotificationStatus() -> String {
        if isNotificationEnabled {
            return "Daily reminder set for \(formatTime(notificationTime))"
        } else {
            return "Notifications disabled"
        }
    }
    
    // MARK: - Testing
    
    public func scheduleTestNotification() {
        guard isNotificationEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "Your daily Mum memory notifications are working!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error)")
            } else {
                print("Test notification scheduled")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate Extension
extension NotificationManager: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "daily_mum_memory" {
            print("User tapped daily reminder notification - will force refresh today's photo")
            
            // Post notification to trigger photo refresh when app becomes active
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("DailyReminderTapped"), object: nil)
            }
        }
        completionHandler()
    }
}