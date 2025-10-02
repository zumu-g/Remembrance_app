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
    @AppStorage("showQuotes") private var showQuotes: Bool = true

    var body: some View {
        let _ = print("SettingsTabView loaded, storeManager status: \(storeManager.subscriptionStatus)")
        NavigationStack {
            ZStack {
                // Sophisticated memorial green background
                Color(red: 51/255, green: 90/255, blue: 76/255)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // App Header
                        appHeader

                        // Display Settings
                        displaySection

                        // Notifications
                        notificationsSection

                        // Subscription
                        subscriptionCard

                        // About
                        aboutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                }
            }
        }
        .onAppear {
            print("⚙️ SettingsTabView appeared - loading notification settings")
            checkNotificationStatus()
            loadSavedTime()
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

    private var appHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))

            Text("Remembrance")
                .font(.system(size: 28, weight: .medium, design: .serif))
                .foregroundColor(.white)

            Text("Memorial Photo App")
                .font(.system(size: 14, weight: .regular, design: .serif))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    // MARK: - Display Section
    private var displaySection: some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                Text("Display")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                    .textCase(.uppercase)
                    .tracking(1.2)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            // Settings Card
            VStack(spacing: 0) {
                // Show Daily Quotes Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Quotes")
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundColor(.white)
                        Text("Show inspirational quotes with photos")
                            .font(.system(size: 13, weight: .regular, design: .serif))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    Toggle("", isOn: $showQuotes)
                        .labelsHidden()
                        .tint(Color(red: 179/255, green: 154/255, blue: 76/255))
                }
                .padding(16)
            }
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
        }
    }

    // MARK: - Notifications Section
    private var notificationsSection: some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                Text("Reminders")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                    .textCase(.uppercase)
                    .tracking(1.2)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            // Settings Card
            VStack(spacing: 0) {
                // Enable Notifications Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Reminders")
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundColor(.white)
                        Text("Receive gentle daily notifications")
                            .font(.system(size: 13, weight: .regular, design: .serif))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    Toggle("", isOn: $notificationsEnabled)
                        .labelsHidden()
                        .tint(Color(red: 179/255, green: 154/255, blue: 76/255))
                        .onChange(of: notificationsEnabled) { enabled in
                            if enabled {
                                requestNotificationPermission()
                            } else {
                                disableNotifications()
                            }
                        }
                }
                .padding(16)

                if notificationsEnabled {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    // Time Picker
                    VStack(spacing: 12) {
                        DatePicker("Notification Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundColor(.white)
                            .onChange(of: notificationTime) { newTime in
                                saveNotificationTime(newTime)
                                scheduleNotification(for: newTime)
                            }

                        Button(action: {
                            sendTestNotification()
                        }) {
                            Text("Send Test Notification")
                                .font(.system(size: 14, weight: .regular, design: .serif))
                                .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                        }
                    }
                    .padding(16)
                }
            }
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
        }
    }

    // MARK: - Subscription Card
    private var subscriptionCard: some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                Text("Subscription")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                    .textCase(.uppercase)
                    .tracking(1.2)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            VStack(spacing: 16) {
                // Status
                subscriptionStatus

                // Subscribe Buttons (if not subscribed)
                if storeManager.subscriptionStatus != .subscribed {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    subscriptionOptions
                }

                // Management Links
                Divider()
                    .background(Color.white.opacity(0.1))

                managementLinks
            }
            .padding(16)
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
        }
    }

    private var subscriptionStatus: some View {
        HStack(spacing: 12) {
            if storeManager.subscriptionStatus == .trial {
                Image(systemName: "hourglass")
                    .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                    .font(.system(size: 18))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Free Trial")
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundColor(.white)
                    Text("\(storeManager.trialDaysRemaining) days remaining")
                        .font(.system(size: 13, weight: .regular, design: .serif))
                        .foregroundColor(.white.opacity(0.6))
                }
            } else if storeManager.subscriptionStatus == .subscribed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                    .font(.system(size: 18))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Premium Member")
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundColor(.white)
                    Text("Full access to all features")
                        .font(.system(size: 13, weight: .regular, design: .serif))
                        .foregroundColor(.white.opacity(0.6))
                }
            } else if storeManager.subscriptionStatus == .expired {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                    .font(.system(size: 18))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Trial Expired")
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundColor(.white)
                    Text("Subscribe to continue")
                        .font(.system(size: 13, weight: .regular, design: .serif))
                        .foregroundColor(.white.opacity(0.6))
                }
            } else {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 18))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Checking Status...")
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundColor(.white)
                }
            }
            Spacer()
        }
    }

    private var subscriptionOptions: some View {
        VStack(spacing: 12) {
            let monthlyProduct = storeManager.products.first(where: { $0.id.contains("monthly") })
            let yearlyProduct = storeManager.products.first(where: { $0.id.contains("yearly") })

            // Monthly
            Button(action: {
                if let product = monthlyProduct {
                    Task { await purchaseProduct(product) }
                } else {
                    showingPaywall = true
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Monthly")
                            .font(.system(size: 15, weight: .medium, design: .serif))
                            .foregroundColor(.white)
                        Text(monthlyProduct?.displayPrice ?? "$2.99/month")
                            .font(.system(size: 13, weight: .regular, design: .serif))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                            .font(.system(size: 22))
                    }
                }
                .padding(14)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
            }
            .disabled(isPurchasing)

            // Yearly
            Button(action: {
                if let product = yearlyProduct {
                    Task { await purchaseProduct(product) }
                } else {
                    showingPaywall = true
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text("Annual")
                                .font(.system(size: 15, weight: .medium, design: .serif))
                                .foregroundColor(.white)
                            Text("SAVE 44%")
                                .font(.system(size: 10, weight: .bold, design: .serif))
                                .foregroundColor(Color(red: 51/255, green: 90/255, blue: 76/255))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(red: 179/255, green: 154/255, blue: 76/255))
                                .cornerRadius(3)
                        }
                        Text(yearlyProduct?.displayPrice ?? "$19.99/year")
                            .font(.system(size: 13, weight: .regular, design: .serif))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                            .font(.system(size: 22))
                    }
                }
                .padding(14)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
            }
            .disabled(isPurchasing)
        }
    }

    private var managementLinks: some View {
        VStack(spacing: 10) {
            if storeManager.subscriptionStatus == .subscribed {
                Button(action: {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "gear")
                            .font(.system(size: 14))
                        Text("Manage Subscription")
                            .font(.system(size: 14, weight: .regular, design: .serif))
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                }
            }

            Button(action: {
                Task {
                    await storeManager.restorePurchases()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                    Text("Restore Purchases")
                        .font(.system(size: 14, weight: .regular, design: .serif))
                    Spacer()
                }
                .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("About")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                    .textCase(.uppercase)
                    .tracking(1.2)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            VStack(spacing: 0) {
                HStack {
                    Text("Version")
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .foregroundColor(.white)
                    Spacer()
                    Text("1.0")
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(16)
            }
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
        }
    }

    // MARK: - Helper Functions
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
        .environmentObject(PhotoStore())
}
