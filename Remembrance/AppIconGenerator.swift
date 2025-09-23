import SwiftUI

struct AppIconGenerator: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background gradient - soft, comforting colors
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.85, blue: 0.9),  // Soft pink
                    Color(red: 0.88, green: 0.92, blue: 0.95)   // Soft blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Main content
            VStack(spacing: size * 0.04) {
                // Heart symbol at the top
                Image(systemName: "heart.fill")
                    .font(.system(size: size * 0.2, weight: .light))
                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.6))
                
                // Number 365 in elegant font
                Text("365")
                    .font(.system(size: size * 0.15, weight: .thin, design: .serif))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                
                // Small subtitle
                Text("days")
                    .font(.system(size: size * 0.08, weight: .ultraLight, design: .serif))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    .opacity(0.8)
            }
            .offset(y: -size * 0.02) // Slightly center upward
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.15))
    }
}

struct AppIconGeneratorAlternative: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background - soft lavender
            Color(red: 0.92, green: 0.88, blue: 0.95)
            
            // Subtle pattern background
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: size * 0.8, height: size * 0.8)
                .blur(radius: size * 0.02)
            
            // Main symbol - photo with heart
            VStack(spacing: size * 0.05) {
                ZStack {
                    // Photo frame
                    RoundedRectangle(cornerRadius: size * 0.03)
                        .fill(Color.white)
                        .frame(width: size * 0.35, height: size * 0.28)
                        .shadow(color: .black.opacity(0.1), radius: size * 0.01)
                    
                    // Heart in photo
                    Image(systemName: "heart.fill")
                        .font(.system(size: size * 0.12))
                        .foregroundColor(Color(red: 0.9, green: 0.6, blue: 0.7))
                }
                
                // Text below
                VStack(spacing: size * 0.01) {
                    Text("365")
                        .font(.system(size: size * 0.12, weight: .light, design: .serif))
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.5))
                    
                    Text("DAYS")
                        .font(.system(size: size * 0.04, weight: .medium, design: .default))
                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.6))
                        .tracking(size * 0.002)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.15))
    }
}

struct AppIconPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("App Icon Designs")
                .font(.title)
                .padding()
            
            HStack(spacing: 30) {
                VStack {
                    AppIconGenerator(size: 120)
                        .shadow(radius: 5)
                    Text("Design 1")
                        .font(.caption)
                }
                
                VStack {
                    AppIconGeneratorAlternative(size: 120)
                        .shadow(radius: 5)
                    Text("Design 2")
                        .font(.caption)
                }
            }
            
            Text("Tap and hold to save icon designs")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
        }
        .padding()
    }
}

#Preview {
    AppIconPreview()
}