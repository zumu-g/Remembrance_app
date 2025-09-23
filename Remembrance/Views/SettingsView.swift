import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager()
    @ObservedObject private var photoManager = PhotoManager.shared
    @State private var showingPhotoImport = false
    @State private var showingDeleteConfirmation = false
    @State private var notificationTime = Date()
    
    private let themes = ["soft", "warm", "cool", "classic"]
    private let fontSizes = ["small", "medium", "large"]
    
    var body: some View {
        NavigationView {
            ZStack {
                PaperBackgroundView()
                
                Form {
                    appInfoSection
                    notificationSection
                    appearanceSection
                    dataSection
                    aboutSection
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Settings")
            }
        }
        .onAppear {
            if let settings = settingsManager.settings {
                notificationTime = settings.notificationTime ?? Date()
            }
        }
        .sheet(isPresented: $showingPhotoImport) {
            PhotoImportView()
        }
        .alert("Delete All Photos", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAllPhotos()
            }
        } message: {
            Text("This will permanently delete all photos and memories. This action cannot be undone.")
        }
    }
    
    private var appInfoSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "heart.circle.fill")
                        .font(.title)
                        .foregroundColor(.pink)
                    
                    VStack(alignment: .leading) {
                        Text("Remembrance")
                            .font(.headline)
                        Text("Memorial Photo App")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let startDate = settingsManager.settings?.startDate {
                    let daysSinceStart = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
                    let currentDay = (daysSinceStart % 365) + 1
                    
                    HStack {
                        Text("Current Day:")
                        Spacer()
                        Text("\(currentDay) of 365")
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var notificationSection: some View {
        Section("Daily Reminders") {
            DatePicker("Notification Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                .onChange(of: notificationTime) { _, newTime in
                    settingsManager.updateNotificationTime(newTime)
                    // NotificationManager will automatically reschedule when settings change
                }
            
            Button("Test Notification") {
                sendTestNotification()
            }
            .foregroundColor(.blue)
        }
    }
    
    private var appearanceSection: some View {
        Section("Appearance") {
            HStack {
                Text("Theme")
                Spacer()
                Picker("Theme", selection: Binding(
                    get: { settingsManager.settings?.selectedTheme ?? "soft" },
                    set: { settingsManager.updateTheme($0) }
                )) {
                    ForEach(themes, id: \.self) { theme in
                        Text(theme.capitalized).tag(theme)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            HStack {
                Text("Font Size")
                Spacer()
                Picker("Font Size", selection: Binding(
                    get: { settingsManager.settings?.fontSize ?? "medium" },
                    set: { settingsManager.updateFontSize($0) }
                )) {
                    ForEach(fontSizes, id: \.self) { size in
                        Text(size.capitalized).tag(size)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }
    
    private var dataSection: some View {
        Section("Photos & Data") {
            HStack {
                Text("Total Photos")
                Spacer()
                Text("\(photoManager.allPhotos.count)")
                    .foregroundColor(.secondary)
            }
            
            Button("Add More Photos") {
                showingPhotoImport = true
            }
            .foregroundColor(.blue)
            
            Button("Delete All Photos") {
                showingDeleteConfirmation = true
            }
            .foregroundColor(.red)
        }
    }
    
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0")
                    .foregroundColor(.secondary)
            }
            
            Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                .foregroundColor(.blue)
            
            Link("Support", destination: URL(string: "mailto:support@example.com")!)
                .foregroundColor(.blue)
        }
    }
    
    
    private func sendTestNotification() {
        NotificationManager.shared.testNotification()
    }
    
    private func deleteAllPhotos() {
        // This would need to be implemented in PhotoManager
        // For now, just a placeholder
        print("Delete all photos functionality would be implemented here")
    }
}

#Preview {
    SettingsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}