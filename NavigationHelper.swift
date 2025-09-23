import SwiftUI

class NavigationHelper: ObservableObject {
    @Published var selectedTab = 0
    
    func goToHome() {
        print("NavigationHelper: Setting selectedTab to 0")
        selectedTab = 0
    }
    
    func goToMemories() {
        print("NavigationHelper: Setting selectedTab to 1")
        selectedTab = 1
    }
    
    func goToQuotes() {
        print("NavigationHelper: Setting selectedTab to 2")
        selectedTab = 2
    }
    
    func goToSettings() {
        print("NavigationHelper: Setting selectedTab to 3")
        selectedTab = 3
    }
}

struct NavigationHelperKey: EnvironmentKey {
    static let defaultValue = NavigationHelper()
}

extension EnvironmentValues {
    var navigationHelper: NavigationHelper {
        get { self[NavigationHelperKey.self] }
        set { self[NavigationHelperKey.self] = newValue }
    }
}

struct HomeButton: View {
    @Environment(\.navigationHelper) private var navigationHelper
    
    var body: some View {
        Button("Home") {
            navigationHelper.goToHome()
        }
        .serifFont(.serifBody)
        .foregroundColor(.pink)
    }
}

struct BottomHomeButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Button(action: {
                print("Arrow button tapped - dismissing view")
                dismiss()
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

#Preview {
    HomeButton()
}