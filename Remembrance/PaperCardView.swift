import SwiftUI

struct PaperCardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.99, green: 0.98, blue: 0.96))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.brown.opacity(0.1), lineWidth: 1)
                    )
            )
    }
}

#Preview {
    PaperCardView {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink)
            
            Text("Sample Card")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("This is a sample paper card view with a subtle background and shadow.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
} 