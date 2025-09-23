import SwiftUI

struct AddTributeView: View {
    let photoDataManager: PhotoDataManager
    let onComplete: () -> Void
    
    @State private var title = ""
    @State private var message = ""
    @State private var authorName = ""
    @State private var isPublic = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                // Green background
                Color(red: 0.075, green: 0.267, blue: 0.176)
                    .ignoresSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 8) {
                            Text("ADD TRIBUTE")
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                            
                            Text("Share a loving tribute or memory")
                                .font(.system(size: 16, weight: .regular, design: .serif))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                .opacity(0.8)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 20) {
                            // Title field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tribute Title")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                
                                TextField("e.g., A Mother's Love, Forever Grateful", text: $title)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.system(size: 16, design: .serif))
                                    .padding(12)
                                    .background(Color.black.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.3), lineWidth: 1)
                                    )
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                            }
                            
                            // Author name field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("From (Optional)")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                
                                TextField("Your name or 'Anonymous'", text: $authorName)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.system(size: 16, design: .serif))
                                    .padding(12)
                                    .background(Color.black.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.3), lineWidth: 1)
                                    )
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                            }
                            
                            // Message field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tribute Message")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                
                                TextEditor(text: $message)
                                    .font(.system(size: 16, design: .serif))
                                    .padding(12)
                                    .background(Color.black.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.3), lineWidth: 1)
                                    )
                                    .frame(height: 150)
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                    .scrollContentBackground(.hidden)
                                
                                Text("Share what made them special, a favorite memory, or words of love and gratitude.")
                                    .font(.system(size: 12, design: .serif))
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                    .opacity(0.6)
                            }
                            
                            // Public toggle
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Toggle(isOn: $isPublic) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text("Public Tribute")
                                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                                
                                                Image(systemName: isPublic ? "globe" : "lock")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.2))
                                            }
                                            
                                            Text(isPublic ? "Others can see this tribute" : "Only you can see this tribute")
                                                .font(.system(size: 14, weight: .regular, design: .serif))
                                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                                .opacity(0.7)
                                        }
                                    }
                                    .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.9, green: 0.7, blue: 0.2)))
                                }
                                .padding(15)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.black.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                            
                            // Inspirational quote
                            VStack(spacing: 8) {
                                Text("💝")
                                    .font(.system(size: 32))
                                
                                Text("\"The love between a mother and child is forever. Though they may be gone from sight, they are never gone from heart.\"")
                                    .font(.system(size: 14, weight: .regular, design: .serif))
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                    .opacity(0.7)
                                    .italic()
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 10)
                            }
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 0.9, green: 0.7, blue: 0.2).opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Action buttons
                        HStack(spacing: 20) {
                            Button("Cancel") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .font(.system(size: 18, weight: .medium, design: .serif))
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.5), lineWidth: 1)
                            )
                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                            
                            Button("Save Tribute") {
                                saveTribute()
                            }
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 0.9, green: 0.7, blue: 0.2))
                            )
                            .foregroundColor(.white)
                            .disabled(title.isEmpty || message.isEmpty)
                            .opacity((title.isEmpty || message.isEmpty) ? 0.6 : 1.0)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func saveTribute() {
        photoDataManager.saveTribute(
            title: title,
            message: message,
            authorName: authorName.isEmpty ? "Anonymous" : authorName,
            isPublic: isPublic
        )
        
        onComplete()
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddTributeView(photoDataManager: PhotoDataManager()) { }
}