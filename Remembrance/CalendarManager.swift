import Foundation
import CoreData

class CalendarManager: ObservableObject {
    @Published var currentDay: Int = 1
    @Published var startDate: Date = Date()
    @Published var completedDays: Set<Int> = []
    
    private let persistenceController = PersistenceController.shared
    
    init() {
        loadSettings()
        calculateCurrentDay()
    }
    
    func loadSettings() {
        let request: NSFetchRequest<Settings> = Settings.fetchRequest()
        
        do {
            let settings = try persistenceController.container.viewContext.fetch(request)
            if let userSettings = settings.first {
                if let savedStartDate = userSettings.startDate {
                    self.startDate = savedStartDate
                } else {
                    // First time setup
                    setupInitialStartDate()
                }
            } else {
                // Create initial settings
                createInitialSettings()
            }
        } catch {
            print("Error loading settings: \(error)")
            setupInitialStartDate()
        }
        
        loadCompletedDays()
    }
    
    private func createInitialSettings() {
        let settings = Settings(context: persistenceController.container.viewContext)
        settings.startDate = Date()
        settings.hasCompletedOnboarding = false
        settings.notificationTime = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())
        settings.selectedTheme = "green"
        settings.fontSize = "medium"
        
        self.startDate = Date()
        
        saveContext()
    }
    
    private func setupInitialStartDate() {
        self.startDate = Date()
        saveStartDate()
    }
    
    func saveStartDate() {
        let request: NSFetchRequest<Settings> = Settings.fetchRequest()
        
        do {
            let settings = try persistenceController.container.viewContext.fetch(request)
            let userSettings = settings.first ?? Settings(context: persistenceController.container.viewContext)
            userSettings.startDate = startDate
            saveContext()
        } catch {
            print("Error saving start date: \(error)")
        }
    }
    
    private func loadCompletedDays() {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        do {
            let photos = try persistenceController.container.viewContext.fetch(request)
            completedDays = Set(photos.compactMap { photo in
                if photo.dayNumber > 0 {
                    return Int(photo.dayNumber)
                }
                return nil
            })
        } catch {
            print("Error loading completed days: \(error)")
        }
    }
    
    func calculateCurrentDay() {
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.day], from: startDate, to: today)
        let daysSinceStart = components.day ?? 0
        
        currentDay = min(max(daysSinceStart + 1, 1), 365)
    }
    
    func getDayNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: date)
        let daysSinceStart = components.day ?? 0
        return min(max(daysSinceStart + 1, 1), 365)
    }
    
    func getDateForDay(_ day: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: day - 1, to: startDate) ?? startDate
    }
    
    func isDayCompleted(_ day: Int) -> Bool {
        return completedDays.contains(day)
    }
    
    func markDayCompleted(_ day: Int) {
        completedDays.insert(day)
    }
    
    func getDaysRemaining() -> Int {
        return max(365 - currentDay + 1, 0)
    }
    
    func getProgressPercentage() -> Double {
        return Double(completedDays.count) / 365.0 * 100.0
    }
    
    func isMemorialComplete() -> Bool {
        return completedDays.count >= 365
    }
    
    private func saveContext() {
        do {
            try persistenceController.container.viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // Helper function to get calendar view data
    func getCalendarData() -> [(day: Int, date: Date, isCompleted: Bool, isCurrent: Bool)] {
        var calendarData: [(day: Int, date: Date, isCompleted: Bool, isCurrent: Bool)] = []
        
        for day in 1...365 {
            let date = getDateForDay(day)
            let isCompleted = isDayCompleted(day)
            let isCurrent = (day == currentDay)
            calendarData.append((day: day, date: date, isCompleted: isCompleted, isCurrent: isCurrent))
        }
        
        return calendarData
    }
}

// Extension for formatting dates
extension CalendarManager {
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }
}