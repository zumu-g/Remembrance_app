import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @StateObject private var settingsManager = SettingsManager()
    @State private var currentStep = 0
    @State private var selectedNotificationTime = Date()
    @State private var showingPhotoImport = false
    @State private var notificationPermissionGranted = false
    @Environment(\.dismiss) private var dismiss
    
    private let totalSteps = 4
    
    var body: some View {
        VStack(spacing: 0) {
            progressBar
            
            Spacer()
            
            currentStepView
            
            Spacer()
            
            navigationButtons
        }
        .padding()
        .onAppear {
            selectedNotificationTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        }
        .sheet(isPresented: $showingPhotoImport) {
            MultiMethodImportView()
        }
    }
    
    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Rectangle()
                    .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
            }
        }
        .padding(.top)
    }
    
    @ViewBuilder
    private var currentStepView: some View {
        switch currentStep {
        case 0:
            welcomeStep
        case 1:
            notificationStep
        case 2:
            photoSetupStep
        case 3:
            completionStep
        default:
            welcomeStep
        }
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.pink)
            
            VStack(spacing: 16) {
                Text("Welcome to Remembrance")
                    .font(.title)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text("A gentle way to honor and remember your mother through daily photos and memories.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                FeatureRow(icon: "photo.on.rectangle", title: "Daily Photos", description: "One meaningful photo each day")
                FeatureRow(icon: "bell", title: "Gentle Reminders", description: "Customizable daily notifications")
                FeatureRow(icon: "heart", title: "Personal Notes", description: "Add memories and thoughts")
                FeatureRow(icon: "lock", title: "Private & Secure", description: "All photos stored locally on your device")
            }
        }
    }
    
    private var notificationStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "bell.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Daily Reminders")
                    .font(.title)
                    .fontWeight(.medium)
                
                Text("Choose when you'd like to receive a gentle reminder to view your daily memory.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 20) {
                DatePicker("Notification Time", selection: $selectedNotificationTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                
                Text("You'll receive a notification at \(selectedNotificationTime, formatter: timeFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var photoSetupStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "photo.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: 16) {
                Text("Add Your Photos")
                    .font(.title)
                    .fontWeight(.medium)
                
                Text("Import photos of your mother to create your memorial collection. You can add up to 365 photos.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 20) {
                Button(action: {
                    showingPhotoImport = true
                }) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                        Text("Import Photos")
                    }
                    .serifFont(.serifHeadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                Text("Don't worry - you can always add more photos later in the app.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var completionStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: 16) {
                Text("You're All Set!")
                    .font(.title)
                    .fontWeight(.medium)
                
                Text("Your memorial app is ready. Each day, you'll see a special photo of your mother and can add personal memories and thoughts.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                InfoCard(title: "Daily Experience", description: "Open the app each day to see your memory and reflect")
                InfoCard(title: "Add Notes", description: "Record thoughts, memories, or feelings about each photo")
                InfoCard(title: "Mark Favorites", description: "Highlight special photos that mean the most to you")
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button("Back") {
                    currentStep -= 1
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            Button(currentStep == totalSteps - 1 ? "Get Started" : "Next") {
                if currentStep == totalSteps - 1 {
                    completeOnboarding()
                } else {
                    if currentStep == 1 {
                        requestNotificationPermission()
                    }
                    currentStep += 1
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(8)
        }
        .padding(.bottom)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                notificationPermissionGranted = granted
                if granted {
                    settingsManager.updateNotificationTime(selectedNotificationTime)
                }
            }
        }
    }
    
    private func completeOnboarding() {
        settingsManager.completeOnboarding()
        settingsManager.setStartDate(Date())
        dismiss()
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct InfoCard: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    OnboardingView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}