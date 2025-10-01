import SwiftUI
import UserNotifications
import StoreKit

struct SettingsTabView: View {
    @Binding var selectedTab: Int
    @State private var notificationTime = Date()
    @State private var notificationsEnabled = false
    @State private var showingPhotoImport = false
    @State private var showingMainPhotoImport = false
    @State private var showingPaywall = false
    @State private var isPurchasing = false
    @State private var showPurchaseError = false
    @State private var purchaseErrorMessage = ""
    @StateObject private var storeManager = StoreKitManager.shared
    
    var body: some View {
        let _ = print("SettingsTabView loaded, storeManager status: \(storeManager.subscriptionStatus)")
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
                
                Form {
                    appInfoSection
                    subscriptionSection
                    photosSection
                    notificationSection
                    aboutSection
                }
                .navigationTitle("Settings")
                .scrollContentBackground(.hidden)
                .background(Color.clear)
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
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .alert("Purchase Error", isPresented: $showPurchaseError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchaseErrorMessage)
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

    private var subscriptionSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 15) {
                // Subscription Status
                HStack {
                    if storeManager.subscriptionStatus == .trial {
                        Image(systemName: "hourglass")
                            .foregroundColor(.orange)
                            .font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Free Trial")
                                .serifFont(.serifHeadline)
                            Text("\(storeManager.trialDaysRemaining) days remaining")
                                .serifFont(.serifSubheadline)
                                .foregroundColor(.secondary)
                        }
                    } else if storeManager.subscriptionStatus == .subscribed {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Premium Member")
                                .serifFont(.serifHeadline)
                            Text("Full access to all features")
                                .serifFont(.serifSubheadline)
                                .foregroundColor(.secondary)
                        }
                    } else if storeManager.subscriptionStatus == .expired {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Trial Expired")
                                .serifFont(.serifHeadline)
                            Text("Subscribe to continue")
                                .serifFont(.serifSubheadline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Checking Status...")
                                .serifFont(.serifHeadline)
                            Text("Please wait")
                                .serifFont(.serifSubheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 5)

                Divider()

                // Subscription Options - Always show unless already subscribed
                let _ = print("🔔 Subscription Status: \(storeManager.subscriptionStatus), Products: \(storeManager.products.count)")

                if storeManager.subscriptionStatus != .subscribed {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Upgrade to Premium")
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(.primary)
                            .padding(.top, 8)

                        // Monthly Option
                        let monthlyProduct = storeManager.products.first(where: { $0.id.contains("monthly") })
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(monthlyProduct?.displayName ?? "Monthly Subscription")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text(monthlyProduct?.displayPrice ?? "$2.99/month")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                if let product = monthlyProduct {
                                    Task {
                                        await purchaseProduct(product)
                                    }
                                } else {
                                    showingPaywall = true
                                }
                            }) {
                                Text("Subscribe Now")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(isPurchasing ? Color.blue.opacity(0.5) : Color.blue)
                                    .cornerRadius(8)
                            }
                            .disabled(isPurchasing)
                        }
                        .padding(.vertical, 4)

                        // Annual Option
                        let yearlyProduct = storeManager.products.first(where: { $0.id.contains("yearly") })
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text(yearlyProduct?.displayName ?? "Annual Subscription")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text("SAVE 44%")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.green)
                                        .cornerRadius(4)
                                }
                                Text(yearlyProduct?.displayPrice ?? "$19.99/year")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                if let product = yearlyProduct {
                                    Task {
                                        await purchaseProduct(product)
                                    }
                                } else {
                                    showingPaywall = true
                                }
                            }) {
                                Text("Subscribe Now")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(isPurchasing ? Color.green.opacity(0.5) : Color.green)
                                    .cornerRadius(8)
                            }
                            .disabled(isPurchasing)
                        }
                        .padding(.vertical, 4)

                        if isPurchasing {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Processing purchase...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.vertical, 10)
                        }
                    }
                    .padding(.vertical, 8)

                    Divider()
                }

                // Management Actions
                VStack(alignment: .leading, spacing: 10) {
                    if storeManager.subscriptionStatus == .subscribed {
                        Button(action: {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "gear")
                                Text("Manage Subscription")
                                    .serifFont(.serifBody)
                            }
                        }
                        .foregroundColor(.blue)

                        Button(action: {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("Cancel Subscription")
                                    .serifFont(.serifBody)
                            }
                        }
                        .foregroundColor(.red)
                    }

                    Button(action: {
                        Task {
                            await storeManager.restorePurchases()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Restore Purchases")
                                .serifFont(.serifBody)
                        }
                    }
                    .foregroundColor(.secondary)
                }

                // Features List
                if storeManager.subscriptionStatus != .subscribed {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Premium Features")
                            .serifFont(.serifHeadline)
                            .foregroundColor(.primary)

                        ForEach([
                            "Unlimited photo storage",
                            "365 daily inspirational quotes",
                            "Complete memorial timeline",
                            "Daily memory reminders",
                            "Priority support"
                        ], id: \.self) { feature in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 12))
                                Text(feature)
                                    .serifFont(.serifSubheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Subscription")
                .serifFont(.serifHeadline)
        } footer: {
            Text("Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period.")
                .serifFont(.serifSubheadline)
                .foregroundColor(.secondary)
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

    private func purchaseProduct(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await storeManager.purchase(product)
            if result != nil {
                print("✅ Purchase successful for \(product.displayName)")
            } else {
                print("⚠️ Purchase was cancelled or pending")
            }
        } catch {
            purchaseErrorMessage = "Purchase failed: \(error.localizedDescription)"
            showPurchaseError = true
            print("❌ Purchase error: \(error)")
        }
    }
}

#Preview {
    SettingsTabView(selectedTab: .constant(2))
}