import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            // Memorial green background - no white flash
            Color(red: 0.2, green: 0.35, blue: 0.3)
                .ignoresSafeArea(.all)
                .background(Color(red: 0.2, green: 0.35, blue: 0.3))
            
            // High resolution app icon only - no text
            if let appIcon = UIImage(named: "1024") ?? UIImage(named: "AppIcon") {
                Image(uiImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 3)
            } else {
                // High-quality fallback
                Image(systemName: "heart.fill")
                    .font(.system(size: 150, weight: .light))
                    .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 3)
            }
        }
    }
}

#Preview {
    LaunchScreen()
}