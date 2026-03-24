import SwiftUI
import UIKit

struct MainTabView: View {
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var navigationHelper = NavigationHelper()
    @State private var showingOnboarding = false
    
    private let memorialGreen = Color(red: 51/255, green: 90/255, blue: 76/255)
    private let matteGold = Color(red: 179/255, green: 154/255, blue: 76/255)

    init() {
        // Set tab bar appearance to memorial green
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 51/255, green: 90/255, blue: 76/255, alpha: 1)

        let normalColor = UIColor(white: 1.0, alpha: 0.6)
        let selectedColor = UIColor(red: 179/255, green: 154/255, blue: 76/255, alpha: 1)

        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = normalColor
        UITabBar.appearance().tintColor = selectedColor
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().barTintColor = UIColor(red: 51/255, green: 90/255, blue: 76/255, alpha: 1)
    }

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
        .tint(matteGold)
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