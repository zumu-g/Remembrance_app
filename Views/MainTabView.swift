import SwiftUI

struct MainTabView: View {
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var navigationHelper = NavigationHelper()
    @State private var showingOnboarding = false
    
    var body: some View {
        TabView(selection: $navigationHelper.selectedTab) {
            DailyPhotoView()
                .tabItem {
                    Image(systemName: "photo")
                    Text("Today")
                }
                .tag(0)
            
            PhotoGalleryView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("Memories")
                }
                .tag(1)
            
            QuotesView()
                .tabItem {
                    Image(systemName: "quote.bubble")
                    Text("Quotes")
                }
                .tag(2)
            
            SettingsTabView(selectedTab: $navigationHelper.selectedTab)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(Color(red: 0.2, green: 0.7, blue: 0.4))
        .onChange(of: navigationHelper.selectedTab) { oldValue, newValue in
            print("Tab selection changed from \(oldValue) to \(newValue)")
        }
        .onAppear {
            // Temporarily disable onboarding to test tab switching
            // checkOnboardingStatus()
            print("MainTabView appeared")
        }
        // Temporarily commented out to test
        // .sheet(isPresented: $showingOnboarding) {
        //     OnboardingView()
        // }
        .environment(\.navigationHelper, navigationHelper)
        .onReceive(NotificationCenter.default.publisher(for: .switchToHomeTab)) { _ in
            navigationHelper.selectedTab = 0
        }
    }
    
    
    private func checkOnboardingStatus() {
        if let settings = settingsManager.settings {
            showingOnboarding = !settings.hasCompletedOnboarding
        } else {
            // Don't show onboarding by default - it might be blocking
            showingOnboarding = false
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}