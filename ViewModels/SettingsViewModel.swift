//
//  SettingsViewModel.swift
//  Remembrance
//
//  Created by Stuart Grant on 8/7/2025.
//

import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var selectedTheme: AppTheme = .green
    @Published var fontSize: FontSize = .medium
    @Published var notificationTime = Date()
    @Published var hasCompletedOnboarding = false
    @Published var startDate = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let settingsManager: SettingsManager
    
    init(settingsManager: SettingsManager = SettingsManager()) {
        self.settingsManager = settingsManager
        loadSettings()
    }
    
    // MARK: - Settings Loading
    
    private func loadSettings() {
        guard let settings = settingsManager.settings else {
            createDefaultSettings()
            return
        }
        
        selectedTheme = AppTheme(rawValue: settings.selectedTheme ?? "green") ?? .green
        fontSize = FontSize(rawValue: settings.fontSize ?? "medium") ?? .medium
        notificationTime = settings.notificationTime ?? Date()
        hasCompletedOnboarding = settings.hasCompletedOnboarding
        startDate = settings.startDate ?? Date()
    }
    
    private func createDefaultSettings() {
        selectedTheme = .green
        fontSize = .medium
        notificationTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        hasCompletedOnboarding = false
        startDate = Date()
        saveAllSettings()
    }
    
    // MARK: - Settings Updates
    
    func updateTheme(_ theme: AppTheme) {
        selectedTheme = theme
        settingsManager.updateTheme(theme.rawValue)
    }
    
    func updateFontSize(_ size: FontSize) {
        fontSize = size
        settingsManager.updateFontSize(size.rawValue)
    }
    
    func updateNotificationTime(_ time: Date) {
        notificationTime = time
        settingsManager.updateNotificationTime(time)
    }
    
    func updateStartDate(_ date: Date) {
        startDate = date
        settingsManager.setStartDate(date)
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        settingsManager.completeOnboarding()
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        settingsManager.settings?.hasCompletedOnboarding = false
        settingsManager.loadSettings()
    }
    
    private func saveAllSettings() {
        settingsManager.updateTheme(selectedTheme.rawValue)
        settingsManager.updateFontSize(fontSize.rawValue)
        settingsManager.updateNotificationTime(notificationTime)
        settingsManager.setStartDate(startDate)
        
        if hasCompletedOnboarding {
            settingsManager.completeOnboarding()
        }
    }
    
    // MARK: - Helper Methods
    
    func getThemeColor(for colorType: ThemeColorType) -> Color {
        return selectedTheme.color(for: colorType)
    }
    
    func getGradientBackground() -> LinearGradient {
        switch selectedTheme {
        case .green:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.85, green: 0.98, blue: 0.92),
                    Color(red: 0.92, green: 0.98, blue: 0.95),
                    Color(red: 0.88, green: 0.96, blue: 0.90)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .soft:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.97, blue: 0.98),
                    Color(red: 0.96, green: 0.98, blue: 0.97)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .warm:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.96, blue: 0.94),
                    Color(red: 0.96, green: 0.95, blue: 0.92)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .classic:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.97, green: 0.97, blue: 0.98),
                    Color(red: 0.95, green: 0.95, blue: 0.96)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    func getFormattedNotificationTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: notificationTime)
    }
    
    func getFormattedStartDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: startDate)
    }
    
    func getDaysSinceStart() -> Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return max(0, days)
    }
    
    func getCurrentCycle() -> Int {
        let daysSinceStart = getDaysSinceStart()
        return (daysSinceStart / 365) + 1
    }
    
    func isValidStartDate(_ date: Date) -> Bool {
        return date <= Date()
    }
    
    // MARK: - Error Handling
    
    func clearError() {
        errorMessage = nil
    }
    
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
}

// MARK: - Supporting Enums

enum AppTheme: String, CaseIterable {
    case soft = "soft"
    case warm = "warm"
    case classic = "classic"
    case green = "green"
    
    var displayName: String {
        switch self {
        case .soft:
            return "Soft Pastels"
        case .warm:
            return "Warm Tones"
        case .classic:
            return "Classic"
        case .green:
            return "Green Gradient"
        }
    }
    
    func color(for type: ThemeColorType) -> Color {
        switch (self, type) {
        case (.soft, .primary):
            return Color(red: 0.9, green: 0.8, blue: 0.9)
        case (.soft, .secondary):
            return Color(red: 0.8, green: 0.9, blue: 0.9)
        case (.soft, .accent):
            return Color(red: 0.9, green: 0.7, blue: 0.8)
        case (.soft, .background):
            return Color(red: 0.98, green: 0.97, blue: 0.98)
            
        case (.warm, .primary):
            return Color(red: 0.8, green: 0.6, blue: 0.4)
        case (.warm, .secondary):
            return Color(red: 0.9, green: 0.7, blue: 0.5)
        case (.warm, .accent):
            return Color(red: 0.7, green: 0.4, blue: 0.3)
        case (.warm, .background):
            return Color(red: 0.98, green: 0.96, blue: 0.94)
            
        case (.classic, .primary):
            return Color(red: 0.2, green: 0.2, blue: 0.3)
        case (.classic, .secondary):
            return Color(red: 0.6, green: 0.6, blue: 0.7)
        case (.classic, .accent):
            return Color(red: 0.4, green: 0.3, blue: 0.5)
        case (.classic, .background):
            return Color(red: 0.97, green: 0.97, blue: 0.98)
            
        case (.green, .primary):
            return Color(red: 0.1, green: 0.3, blue: 0.2)
        case (.green, .secondary):
            return Color(red: 0.4, green: 0.6, blue: 0.5)
        case (.green, .accent):
            return Color(red: 0.2, green: 0.7, blue: 0.4)
        case (.green, .background):
            return Color(red: 0.9, green: 0.98, blue: 0.95)
        }
    }
}

enum FontSize: String, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    
    var displayName: String {
        switch self {
        case .small:
            return "Small"
        case .medium:
            return "Medium"
        case .large:
            return "Large"
        }
    }
    
    var scaleFactor: CGFloat {
        switch self {
        case .small:
            return 0.85
        case .medium:
            return 1.0
        case .large:
            return 1.15
        }
    }
}

enum ThemeColorType {
    case primary
    case secondary
    case accent
    case background
}