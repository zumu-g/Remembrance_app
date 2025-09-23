import SwiftUI
import UIKit

struct IconGeneratorView: View {
    @State private var selectedDesign = 1
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let iconSizes: [(name: String, size: CGFloat)] = [
        ("AppIcon-20x20", 20),
        ("AppIcon-20x20@2x", 40),
        ("AppIcon-20x20@3x", 60),
        ("AppIcon-29x29", 29),
        ("AppIcon-29x29@2x", 58),
        ("AppIcon-29x29@3x", 87),
        ("AppIcon-40x40", 40),
        ("AppIcon-40x40@2x", 80),
        ("AppIcon-40x40@3x", 120),
        ("AppIcon-60x60@2x", 120),
        ("AppIcon-60x60@3x", 180),
        ("AppIcon-76x76", 76),
        ("AppIcon-76x76@2x", 152),
        ("AppIcon-83.5x83.5@2x", 167),
        ("AppIcon-1024x1024", 1024)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Design selection
                    VStack(spacing: 20) {
                        Text("Choose Icon Design")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 30) {
                            VStack {
                                AppIconGenerator(size: 120)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(selectedDesign == 1 ? Color.blue : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        selectedDesign = 1
                                    }
                                
                                Text("Design 1")
                                    .font(.caption)
                                    .foregroundColor(selectedDesign == 1 ? .blue : .secondary)
                            }
                            
                            VStack {
                                AppIconGeneratorAlternative(size: 120)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(selectedDesign == 2 ? Color.blue : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        selectedDesign = 2
                                    }
                                
                                Text("Design 2")
                                    .font(.caption)
                                    .foregroundColor(selectedDesign == 2 ? .blue : .secondary)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Preview at different sizes
                    VStack(spacing: 20) {
                        Text("Preview at Different Sizes")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 15) {
                            ForEach([29, 40, 60, 76], id: \.self) { size in
                                VStack {
                                    if selectedDesign == 1 {
                                        AppIconGenerator(size: CGFloat(size))
                                    } else {
                                        AppIconGeneratorAlternative(size: CGFloat(size))
                                    }
                                    Text("\(size)pt")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Instructions
                    VStack(spacing: 15) {
                        Text("How to Save Icons")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            instructionRow("1", "Take screenshots of the generated icons")
                            instructionRow("2", "Use online tools to resize to required dimensions")
                            instructionRow("3", "Save as PNG files with exact names shown below")
                            instructionRow("4", "Add files to AppIcon.appiconset folder")
                        }
                        .padding(.horizontal)
                    }
                    
                    // Required files list
                    VStack(spacing: 15) {
                        Text("Required Files")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            ForEach(iconSizes, id: \.name) { iconSize in
                                HStack {
                                    Text(iconSize.name)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("\(Int(iconSize.size))×\(Int(iconSize.size))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(6)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Generate button for demonstration
                    Button(action: generateIconInstructions) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Show Generation Instructions")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Icon Generator")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Icon Generation", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func instructionRow(_ number: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    private func generateIconInstructions() {
        alertMessage = """
        To generate app icons:
        
        1. Screenshot the selected design at full size
        2. Use an online icon generator like:
           • appicon.co
           • makeappicon.com
           • iconscout.com/icon-editor
        
        3. Upload your screenshot and download all sizes
        4. Rename files to match the required names
        5. Copy to your AppIcon.appiconset folder
        
        The designs are optimized for clarity at small sizes.
        """
        showingAlert = true
    }
}

#Preview {
    IconGeneratorView()
}