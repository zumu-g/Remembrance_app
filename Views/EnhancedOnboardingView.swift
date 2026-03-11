import SwiftUI
import PhotosUI
import UserNotifications

struct EnhancedOnboardingView: View {
    @EnvironmentObject var photoStore: PhotoStore
    @EnvironmentObject var simpleSettings: SimpleSettingsManager
    @State private var currentStep = 0
    @State private var selectedNotificationTime = Date()
    @State private var showingPhotoImport = false
    @State private var notificationPermissionGranted = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var importedPhotosCount = 0
    @Environment(\.dismiss) private var dismiss

    private let totalSteps = 7

    var body: some View {
        ZStack {
            // Memorial green background
            Color(red: 0.2, green: 0.35, blue: 0.3)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                progressBar
                    .padding(.horizontal)
                    .padding(.top, 10)

                // Main content
                TabView(selection: $currentStep) {
                    ForEach(0..<totalSteps, id: \.self) { step in
                        stepContent(for: step)
                            .tag(step)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)

                // Navigation buttons
                navigationButtons
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
        }
    }

    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.white : Color.white.opacity(0.3))
                    .frame(height: 6)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private func stepContent(for step: Int) -> some View {
        ScrollView {
            VStack(spacing: 30) {
                switch step {
                case 0:
                    welcomeScreen
                case 1:
                    howItWorksScreen
                case 2:
                    photoImportTutorial
                case 3:
                    photoImportAction
                case 4:
                    notificationSetup
                case 5:
                    featuresOverview
                case 6:
                    completionScreen
                default:
                    welcomeScreen
                }
            }
            .padding()
            .padding(.top, 20)
        }
    }

    // MARK: - Step 1: Welcome
    private var welcomeScreen: some View {
        VStack(spacing: 30) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                .shadow(radius: 10)

            VStack(spacing: 16) {
                Text("Welcome to Remembrance")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("A gentle space to celebrate and remember your loved one through daily photos and memories")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 50)

            VStack(alignment: .leading, spacing: 20) {
                FeatureHighlight(
                    icon: "photo.fill",
                    title: "Daily Photo",
                    description: "See one special photo each day"
                )
                FeatureHighlight(
                    icon: "quote.bubble.fill",
                    title: "Inspiring Quotes",
                    description: "Read comforting words of remembrance"
                )
                FeatureHighlight(
                    icon: "bell.fill",
                    title: "Gentle Reminders",
                    description: "Optional daily notifications"
                )
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Step 2: How It Works
    private var howItWorksScreen: some View {
        VStack(spacing: 30) {
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))

            Text("How Remembrance Works")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            VStack(spacing: 25) {
                StepExplanation(
                    number: "1",
                    title: "Add Your Photos",
                    description: "Import meaningful photos from your photo library"
                )

                StepExplanation(
                    number: "2",
                    title: "Daily Selection",
                    description: "The app selects one photo each day for you to reflect on"
                )

                StepExplanation(
                    number: "3",
                    title: "View & Remember",
                    description: "Open the app to see today's photo and quote"
                )

                StepExplanation(
                    number: "4",
                    title: "Browse Memories",
                    description: "Explore past days in your timeline"
                )
            }
        }
    }

    // MARK: - Step 3: Photo Import Tutorial
    private var photoImportTutorial: some View {
        VStack(spacing: 30) {
            Image(systemName: "photo.stack.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))

            Text("Adding Your Photos")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 20) {
                ImportStep(
                    icon: "photo.badge.plus",
                    instruction: "Tap 'Select Photos' to open your photo library"
                )

                ImportStep(
                    icon: "hand.tap.fill",
                    instruction: "Select multiple photos at once by tapping each one"
                )

                ImportStep(
                    icon: "checkmark.circle.fill",
                    instruction: "Tap 'Add' when you've selected all the photos you want"
                )

                ImportStep(
                    icon: "info.circle.fill",
                    instruction: "You can add up to 365 photos (one for each day)"
                )
            }
            .padding(.horizontal)

            Text("Don't worry - you can always add or remove photos later from the Gallery tab")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    // MARK: - Step 4: Photo Import Action
    private var photoImportAction: some View {
        VStack(spacing: 30) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))

            Text("Let's Add Your Photos")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            if importedPhotosCount > 0 {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(importedPhotosCount) photos added")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
            }

            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: 365,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack {
                    Image(systemName: "photo.badge.plus.fill")
                        .font(.title2)
                    Text("Select Photos")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.7, green: 0.6, blue: 0.3))
                .cornerRadius(12)
            }
            .onChange(of: selectedPhotos) { items in
                Task {
                    await loadPhotos(from: items)
                }
            }

            VStack(spacing: 10) {
                Text("Tips for choosing photos:")
                    .font(.headline)
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 8) {
                    Label("Photos that capture happy memories", systemImage: "heart.fill")
                    Label("Different moments throughout life", systemImage: "clock.fill")
                    Label("Photos that make you smile", systemImage: "face.smiling.fill")
                }
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)

            if importedPhotosCount == 0 {
                Text("You can skip this step and add photos later")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }

    // MARK: - Step 5: Notification Setup
    private var notificationSetup: some View {
        VStack(spacing: 30) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))

            Text("Daily Reminders")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Would you like a gentle reminder to view your daily memory?")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                    Text("Choose notification time:")
                        .foregroundColor(.white)
                }

                DatePicker(
                    "",
                    selection: $selectedNotificationTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .colorScheme(.dark)
                .frame(height: 150)
                .clipped()

                Text("You'll receive a notification at \(selectedNotificationTime, formatter: timeFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
            }

            Button(action: {
                requestNotificationPermission()
            }) {
                HStack {
                    Image(systemName: notificationPermissionGranted ? "checkmark.circle.fill" : "bell.fill")
                    Text(notificationPermissionGranted ? "Notifications Enabled" : "Enable Notifications")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(notificationPermissionGranted ? Color.green : Color(red: 0.7, green: 0.6, blue: 0.3))
                .cornerRadius(12)
            }

            Text("You can change this anytime in Settings")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }

    // MARK: - Step 6: Features Overview
    private var featuresOverview: some View {
        VStack(spacing: 30) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 80))
                .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))

            Text("App Features")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            VStack(spacing: 20) {
                FeatureCard(
                    icon: "sun.max.fill",
                    title: "Today Tab",
                    description: "View today's photo and quote. Tap the photo to see it full-screen.",
                    color: .orange
                )

                FeatureCard(
                    icon: "calendar",
                    title: "Timeline Tab",
                    description: "Browse through past days and see previous photos and quotes.",
                    color: .blue
                )

                FeatureCard(
                    icon: "photo.stack",
                    title: "Gallery Tab",
                    description: "View and manage all your photos. Add new ones or remove existing ones.",
                    color: .green
                )

                FeatureCard(
                    icon: "gearshape.fill",
                    title: "Settings Tab",
                    description: "Adjust notification time, manage photos, and customize your experience.",
                    color: .purple
                )
            }
        }
    }

    // MARK: - Step 7: Completion
    private var completionScreen: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
            }

            Text("You're All Set!")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundColor(.white)

            Text("Your memorial space is ready. Open the app each day to see a special photo and reflect on beautiful memories.")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 15) {
                QuickTip(
                    icon: "lightbulb.fill",
                    tip: "Check the app daily for your new photo"
                )

                QuickTip(
                    icon: "heart.fill",
                    tip: "Take a moment to reflect and remember"
                )

                QuickTip(
                    icon: "photo.fill.on.rectangle.fill",
                    tip: "Add more photos anytime from the Gallery"
                )
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)

            Spacer(minLength: 30)
        }
    }

    // MARK: - Navigation
    private var navigationButtons: some View {
        HStack {
            // Back button
            if currentStep > 0 {
                Button(action: {
                    withAnimation {
                        currentStep -= 1
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
            }

            Spacer()

            // Skip button (for photo import step)
            if currentStep == 3 && importedPhotosCount == 0 {
                Button("Skip") {
                    withAnimation {
                        currentStep += 1
                    }
                }
                .foregroundColor(.white.opacity(0.7))
                .padding(.trailing, 10)
            }

            // Next/Complete button
            Button(action: {
                if currentStep == totalSteps - 1 {
                    completeOnboarding()
                } else {
                    withAnimation {
                        currentStep += 1
                    }
                }
            }) {
                HStack {
                    Text(buttonTitle)
                    if currentStep < totalSteps - 1 {
                        Image(systemName: "chevron.right")
                    }
                }
                .foregroundColor(Color(red: 0.2, green: 0.35, blue: 0.3))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(8)
            }
        }
    }

    private var buttonTitle: String {
        switch currentStep {
        case totalSteps - 1:
            return "Start Using App"
        case 3:
            return importedPhotosCount > 0 ? "Continue" : "Next"
        default:
            return "Next"
        }
    }

    // MARK: - Helper Functions
    private func loadPhotos(from items: [PhotosPickerItem]) async {
        var loadedCount = 0

        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    photoStore.images.append(uiImage)
                    loadedCount += 1
                }
            }
        }

        await MainActor.run {
            importedPhotosCount = loadedCount
            selectedPhotos = []
            // Save images immediately after loading
            photoStore.saveImages()
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                notificationPermissionGranted = granted
                if granted {
                    simpleSettings.isNotificationsEnabled = true
                    simpleSettings.updateNotificationTime(selectedNotificationTime)

                    // Schedule the notification
                    NotificationManager.shared.scheduleDailyNotification(at: selectedNotificationTime)
                }
            }
        }
    }

    private func completeOnboarding() {
        simpleSettings.hasCompletedOnboarding = true
        simpleSettings.startDate = Date()
        photoStore.saveImages()
        dismiss()
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - Supporting Views

struct FeatureHighlight: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                .frame(width: 35)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
    }
}

struct StepExplanation: View {
    let number: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.7, green: 0.6, blue: 0.3))
                    .frame(width: 40, height: 40)

                Text(number)
                    .font(.headline)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ImportStep: View {
    let icon: String
    let instruction: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                .frame(width: 30)

            Text(instruction)
                .font(.subheadline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 35)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct QuickTip: View {
    let icon: String
    let tip: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))

            Text(tip)
                .font(.subheadline)
                .foregroundColor(.white)

            Spacer()
        }
    }
}

#Preview {
    EnhancedOnboardingView()
}