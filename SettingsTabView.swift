import SwiftUI
import UserNotifications

struct SettingsTabView: View {
    @Binding var selectedTab: Int
    @State private var notificationTime = Date()
    @State private var notificationsEnabled = false
    @State private var showingPhotoImport = false
    @State private var showingMainPhotoImport = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Add gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.85, green: 0.98, blue: 0.92),
                        Color(red: 0.92, green: 0.98, blue: 0.95),
                        Color(red: 0.88, green: 0.96, blue: 0.90)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Form {
                        appInfoSection
                        photosSection
                        notificationSection
                        aboutSection
                    }
                    .navigationTitle("Settings")
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                
                // Simple back button
                HStack {
                    Button(action: {
                        print("Back button tapped - setting selectedTab to 0")
                        selectedTab = 0
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.clear)
                            .contentShape(Rectangle())
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
                }
            }
        }
        .onAppear {
            print("⚙️ SettingsTabView appeared - loading notification settings")
            checkNotificationStatus()
            loadSavedTime()
        }
        .sheet(isPresented: $showingPhotoImport) {
            MultiMethodImportView()
        }
        .sheet(isPresented: $showingMainPhotoImport) {
            MainPhotoImportView()
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
                            .serifFont(.serifHeadline)
                        Text("Memorial Photo App")
                            .serifFont(.serifSubheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var photosSection: some View {
        Section {
            Button("Set Main Portrait") {
                showingMainPhotoImport = true
            }
            .serifFont(.serifBody)
            .foregroundColor(.pink)
            
            Button("Import Memorial Photos") {
                showingPhotoImport = true
            }
            .serifFont(.serifBody)
            .foregroundColor(.blue)
            
            HStack {
                Text("Total Photos")
                    .serifFont(.serifBody)
                Spacer()
                Text("0") // This would be connected to PhotoManager
                    .serifFont(.serifBody)
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Memorial Photos")
                .serifFont(.serifHeadline)
        }
    }
    
    private var notificationSection: some View {
        Section {
            Toggle("Enable Notifications", isOn: $notificationsEnabled)
                .serifFont(.serifBody)
                .onChange(of: notificationsEnabled) { _, enabled in
                    if enabled {
                        requestNotificationPermission()
                    } else {
                        disableNotifications()
                    }
                }
            
            if notificationsEnabled {
                DatePicker("Notification Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                    .serifFont(.serifBody)
                    .onChange(of: notificationTime) { _, newTime in
                        saveNotificationTime(newTime)
                        scheduleNotification(for: newTime)
                    }
                
                Button("Test Notification") {
                    sendTestNotification()
                }
                .serifFont(.serifBody)
                .foregroundColor(.blue)
            }
        } header: {
            Text("Daily Reminders")
                .serifFont(.serifHeadline)
        }
    }
    
    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                    .serifFont(.serifBody)
                Spacer()
                Text("1.0")
                    .serifFont(.serifBody)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Status")
                    .serifFont(.serifBody)
                Spacer()
                Text("Basic Version")
                    .serifFont(.serifBody)
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("About")
                .serifFont(.serifHeadline)
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func loadSavedTime() {
        if let savedTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date {
            notificationTime = savedTime
        } else {
            notificationTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        }
    }
    
    private func saveNotificationTime(_ time: Date) {
        UserDefaults.standard.set(time, forKey: "notificationTime")
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                notificationsEnabled = granted
                if granted {
                    scheduleNotification(for: notificationTime)
                }
            }
        }
    }
    
    private func disableNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func scheduleNotification(for time: Date) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Today's Memory"
        content.body = "A special memory of your mum is ready to view"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-memory", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func sendTestNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test of your daily memory reminder"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test-notification", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error sending test notification: \(error)")
            }
        }
    }
}

#Preview {
    SettingsTabView(selectedTab: .constant(2))
}