import SwiftUI
import PhotosUI
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var photoStore: PhotoStore
    @State private var selectedTab = 0
    @State private var showingPhotoPicker = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var tabBarVisible = true
    @State private var showingPaywall = false
    @StateObject private var storeManager = StoreKitManager.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(photoStore: photoStore, tabBarVisible: $tabBarVisible)
                .tabItem {
                    Image(systemName: "photo")
                    Text("Today")
                }
                .tag(0)
            
            MemoryCalendarView(photoStore: photoStore)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Timeline")
                }
                .tag(1)
            
            GalleryView(photoStore: photoStore)
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("Gallery")
                }
                .tag(2)
            
            SimpleSettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(Color(red: 1.0, green: 0.8, blue: 0.2))
        .toolbar(tabBarVisible ? .visible : .hidden, for: .tabBar)
        .animation(.none, value: selectedTab)
        .onAppear {
            // Set tab bar background to green
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.3, alpha: 1.0)
            appearance.shadowColor = .clear
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .onChange(of: selectedTab) { newValue in
            if newValue != 0 {
                // Show tab bar when not on Today tab
                tabBarVisible = true
            }
        }
        .onAppear {
            checkSubscriptionStatus()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedItems, maxSelectionCount: 500, matching: .images)
        .onChange(of: selectedItems) { newItems in
            Task {
                var newImages: [UIImage] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        newImages.append(image)
                    }
                }
                await MainActor.run {
                    photoStore.addImages(newImages)
                    selectedItems = []
                }
            }
        }
    }

    private func checkSubscriptionStatus() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            if storeManager.needsPaywall {
                showingPaywall = true
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PhotoStore())
}