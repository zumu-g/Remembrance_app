//
//  ErrorHandler.swift
//  Remembrance
//
//  Created by Stuart Grant on 8/7/2025.
//

import Foundation
import os.log

class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()
    
    @Published var currentError: AppError?
    @Published var showErrorAlert = false
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Remembrance", category: "ErrorHandler")
    
    private init() {}
    
    func handle(_ error: Error, context: String = "") {
        let appError = AppError.from(error, context: context)
        
        DispatchQueue.main.async {
            self.currentError = appError
            self.showErrorAlert = true
        }
        
        logError(appError)
    }
    
    func handle(_ appError: AppError) {
        DispatchQueue.main.async {
            self.currentError = appError
            self.showErrorAlert = true
        }
        
        logError(appError)
    }
    
    func clearError() {
        currentError = nil
        showErrorAlert = false
    }
    
    private func logError(_ error: AppError) {
        let logMessage = """
        Error: \(error.title)
        Description: \(error.message)
        Context: \(error.context)
        Recovery: \(error.recoverySuggestion)
        """
        
        switch error.severity {
        case .low:
            logger.info("\(logMessage)")
        case .medium:
            logger.notice("\(logMessage)")
        case .high:
            logger.error("\(logMessage)")
        case .critical:
            logger.fault("\(logMessage)")
        }
    }
}

// MARK: - App Error Types

struct AppError: LocalizedError, Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let context: String
    let recoverySuggestion: String
    let severity: ErrorSeverity
    
    var errorDescription: String? {
        return message
    }
    
    var failureReason: String? {
        return title
    }
    
    var recoveryOptions: [String]? {
        return [recoverySuggestion]
    }
    
    static func from(_ error: Error, context: String = "") -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        // Core Data errors
        if let nsError = error as NSError?, nsError.domain == "NSCocoaErrorDomain" {
            return AppError(
                title: "Data Error",
                message: "Failed to save or retrieve data",
                context: context,
                recoverySuggestion: "Please try restarting the app",
                severity: .high
            )
        }
        
        // File system errors
        if let nsError = error as NSError?, nsError.domain == NSCocoaErrorDomain {
            return AppError(
                title: "File Error",
                message: "Failed to access photos",
                context: context,
                recoverySuggestion: "Check available storage space",
                severity: .medium
            )
        }
        
        // Generic error
        return AppError(
            title: "Unexpected Error",
            message: error.localizedDescription,
            context: context,
            recoverySuggestion: "Please try again",
            severity: .medium
        )
    }
}

enum ErrorSeverity {
    case low      // Info/warnings
    case medium   // User-facing issues
    case high     // Critical app functionality affected
    case critical // App-breaking issues
}

// MARK: - Specific Error Types

extension AppError {
    static func photoLoadFailed(context: String = "") -> AppError {
        return AppError(
            title: "Photo Load Failed",
            message: "Unable to load today's photo",
            context: context,
            recoverySuggestion: "Try refreshing or check if photos are properly imported",
            severity: .high
        )
    }
    
    static func photoSaveFailed(context: String = "") -> AppError {
        return AppError(
            title: "Photo Save Failed",
            message: "Unable to save photo to device",
            context: context,
            recoverySuggestion: "Check available storage space and try again",
            severity: .high
        )
    }
    
    static func settingsLoadFailed(context: String = "") -> AppError {
        return AppError(
            title: "Settings Error",
            message: "Unable to load app settings",
            context: context,
            recoverySuggestion: "Settings will be reset to defaults",
            severity: .medium
        )
    }
    
    static func notificationPermissionDenied(context: String = "") -> AppError {
        return AppError(
            title: "Notifications Disabled",
            message: "Daily reminders require notification permission",
            context: context,
            recoverySuggestion: "Enable notifications in Settings app",
            severity: .medium
        )
    }
    
    static func insufficientStorage(context: String = "") -> AppError {
        return AppError(
            title: "Storage Full",
            message: "Not enough space to store photos",
            context: context,
            recoverySuggestion: "Free up storage space and try again",
            severity: .high
        )
    }
    
    static func invalidPhotoCount(count: Int, context: String = "") -> AppError {
        return AppError(
            title: "Invalid Photo Count",
            message: "Expected 365 photos, but got \(count)",
            context: context,
            recoverySuggestion: "Please select exactly 365 photos",
            severity: .medium
        )
    }
    
    static func corruptedPhoto(context: String = "") -> AppError {
        return AppError(
            title: "Corrupted Photo",
            message: "One or more photos cannot be displayed",
            context: context,
            recoverySuggestion: "Try re-importing the affected photos",
            severity: .medium
        )
    }
}