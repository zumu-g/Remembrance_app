import SwiftUI

struct AddSpecialDateView: View {
    let photoDataManager: PhotoDataManager
    let onComplete: () -> Void
    
    @State private var title = ""
    @State private var content = ""
    @State private var specialDate = Date()
    @State private var isAnnual = true
    
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
                            Text("ADD SPECIAL DATE")
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                            
                            Text("Mark important dates to remember")
                                .font(.system(size: 16, weight: .regular, design: .serif))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                .opacity(0.8)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 20) {
                            // Title field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Event Title")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                
                                TextField("e.g., Mom's Birthday, Anniversary", text: $title)
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
                            
                            // Date picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Date")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                
                                DatePicker("", selection: $specialDate, displayedComponents: .date)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .colorScheme(.dark)
                                    .accentColor(Color(red: 0.9, green: 0.7, blue: 0.2))
                                    .frame(height: 120)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.black.opacity(0.1))
                                    )
                            }
                            
                            // Annual toggle
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Toggle(isOn: $isAnnual) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Annual Reminder")
                                                .font(.system(size: 16, weight: .medium, design: .serif))
                                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                            
                                            Text("Remind me every year on this date")
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
                            
                            // Description field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description (Optional)")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                
                                TextEditor(text: $content)
                                    .font(.system(size: 16, design: .serif))
                                    .padding(12)
                                    .background(Color.black.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.3), lineWidth: 1)
                                    )
                                    .frame(height: 100)
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                    .scrollContentBackground(.hidden)
                            }
                            
                            // Example dates
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Suggestion")
                                    .font(.system(size: 14, weight: .medium, design: .serif))
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                    .opacity(0.8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("• Birthdays and anniversaries")
                                    Text("• First day we met")
                                    Text("• Graduation or achievement dates")
                                    Text("• Special holidays we celebrated")
                                }
                                .font(.system(size: 12, design: .serif))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                .opacity(0.6)
                                .padding(.leading, 8)
                            }
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
                            
                            Button("Add Special Date") {
                                saveSpecialDate()
                            }
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 0.9, green: 0.7, blue: 0.2))
                            )
                            .foregroundColor(.white)
                            .disabled(title.isEmpty)
                            .opacity(title.isEmpty ? 0.6 : 1.0)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func saveSpecialDate() {
        photoDataManager.saveMemory(
            title: title,
            content: content,
            date: specialDate,
            category: "special",
            associatedPhoto: nil
        )
        
        onComplete()
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddSpecialDateView(photoDataManager: PhotoDataManager()) { }
}