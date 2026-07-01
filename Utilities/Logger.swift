//
//  Logger.swift
//  Remembrance
//
//  Created by Stuart Grant on 8/7/2025.
//

import Foundation
import os.log

struct AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "Remembrance"
    
    static let general = Logger(subsystem: subsystem, category: "General")
    static let photos = Logger(subsystem: subsystem, category: "Photos")
    static let settings = Logger(subsystem: subsystem, category: "Settings")
    static let notifications = Logger(subsystem: subsystem, category: "Notifications")
    static let coreData = Logger(subsystem: subsystem, category: "CoreData")
    static let ui = Logger(subsystem: subsystem, category: "UI")
    static let performance = Logger(subsystem: subsystem, category: "Performance")
}

// MARK: - Logging Extensions

extension PhotoManager {
    func logPhotoOperation(_ operation: String, details: String = "") {
        AppLogger.photos.info("PhotoManager - \(operation): \(details)")
    }
    
    func logPhotoError(_ operation: String, error: Error) {
        AppLogger.photos.error("PhotoManager - \(operation) failed: \(error.localizedDescription)")
    }
}

extension SettingsManager {
    func logSettingsOperation(_ operation: String, details: String = "") {
        AppLogger.settings.info("SettingsManager - \(operation): \(details)")
    }
    
    func logSettingsError(_ operation: String, error: Error) {
        AppLogger.settings.error("SettingsManager - \(operation) failed: \(error.localizedDescription)")
    }
}

extension PersistenceController {
    func logCoreDataOperation(_ operation: String, details: String = "") {
        AppLogger.coreData.info("PersistenceController - \(operation): \(details)")
    }
    
    func logCoreDataError(_ operation: String, error: Error) {
        AppLogger.coreData.error("PersistenceController - \(operation) failed: \(error.localizedDescription)")
    }
}

// MARK: - Performance Logging

struct PerformanceTimer {
    let name: String
    let startTime: CFAbsoluteTime
    
    init(_ name: String) {
        self.name = name
        self.startTime = CFAbsoluteTimeGetCurrent()
        AppLogger.performance.debug("⏱️ Started: \(name)")
    }
    
    func end() {
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        AppLogger.performance.info("⏱️ Completed: \(name) in \(String(format: "%.2f", timeElapsed))s")
    }
}

// MARK: - Usage Examples

/*
// In PhotoManager
func loadTodaysPhoto() {
    let timer = PerformanceTimer("loadTodaysPhoto")
    logPhotoOperation("loadTodaysPhoto", details: "Starting photo load")
    
    // ... existing code ...
    
    do {
        let photos = try viewContext.fetch(request)
        currentPhoto = photos.first
        logPhotoOperation("loadTodaysPhoto", details: "Successfully loaded photo for day \(currentDayNumber)")
        timer.end()
    } catch {
        logPhotoError("loadTodaysPhoto", error: error)
        timer.end()
        throw error
    }
}

// In SettingsManager
func updateTheme(_ theme: String) {
    logSettingsOperation("updateTheme", details: "Changing theme to \(theme)")
    settings?.selectedTheme = theme
    saveContext()
}
*/