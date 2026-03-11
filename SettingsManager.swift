import Foundation
import CoreData

class SettingsManager: ObservableObject {
    private let persistenceController = PersistenceController.shared
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    @Published var settings: Settings?
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        let request: NSFetchRequest<Settings> = Settings.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let fetchedSettings = try viewContext.fetch(request)
            settings = fetchedSettings.first
            if settings == nil {
                createDefaultSettings()
            }
            print("Settings loaded successfully: \(settings != nil)")
        } catch {
            print("Error fetching settings: \(error)")
            createDefaultSettings()
        }
    }
    
    private func createDefaultSettings() {
        let newSettings = Settings(context: viewContext)
        newSettings.notificationTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())
        newSettings.selectedTheme = "soft"
        newSettings.fontSize = "medium"
        newSettings.hasCompletedOnboarding = false
        newSettings.startDate = Date()
        
        settings = newSettings
        saveContext()
    }
    
    func updateNotificationTime(_ time: Date) {
        settings?.notificationTime = time
        saveContext()
        
        // Reschedule notifications with new time
        NotificationManager.shared.rescheduleNotifications()
    }
    
    func updateTheme(_ theme: String) {
        settings?.selectedTheme = theme
        saveContext()
    }
    
    func updateFontSize(_ size: String) {
        settings?.fontSize = size
        saveContext()
    }
    
    func completeOnboarding() {
        settings?.hasCompletedOnboarding = true
        saveContext()
    }
    
    func setStartDate(_ date: Date) {
        settings?.startDate = date
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving settings: \(error)")
        }
    }
}