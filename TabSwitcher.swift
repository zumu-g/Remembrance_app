import SwiftUI

// Global notification to switch tabs
extension Notification.Name {
    static let switchToHomeTab = Notification.Name("switchToHomeTab")
}

struct TabSwitcherButton: View {
    var body: some View {
        HStack {
            Button(action: {
                print("Tab switcher button tapped - going to home")
                NotificationCenter.default.post(name: .switchToHomeTab, object: nil)
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
    TabSwitcherButton()
}