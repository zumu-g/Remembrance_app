import SwiftUI

struct PaperBackgroundView: View {
    var body: some View {
        ZStack {
            // Base paper color
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()
            
            // Subtle texture overlay
            Canvas { context, size in
                // Create a subtle paper grain effect
                for _ in 0..<100 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let opacity = Double.random(in: 0.02...0.08)
                    
                    context.opacity = opacity
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                        with: .color(.brown)
                    )
                }
                
                // Add some very subtle lines for paper texture
                for i in stride(from: 0, through: size.height, by: 40) {
                    let opacity = Double.random(in: 0.01...0.03)
                    context.opacity = opacity
                    context.stroke(
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: i))
                            path.addLine(to: CGPoint(x: size.width, y: i))
                        },
                        with: .color(.gray),
                        lineWidth: 0.5
                    )
                }
            }
        }
    }
}


#Preview {
    PaperBackgroundView()
}