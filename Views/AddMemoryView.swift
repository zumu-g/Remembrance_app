import SwiftUI

struct AddMemoryView: View {
    let photoDataManager: PhotoDataManager
    let onComplete: () -> Void
    
    @State private var title = ""
    @State private var content = ""
    @State private var memoryDate = Date()
    @State private var category = "general"
    @State private var selectedPhoto: Photo?
    @State private var showingPhotoPicker = false
    
    @Environment(\.presentationMode) var presentationMode
    
    private let categories = ["general", "milestone", "funny", "touching", "adventure"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Green background
                Color(red: 0.075, green: 0.267, blue: 0.176)
                    .ignoresSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        Text("ADD MEMORY")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                            .padding(.top, 20)
                        
                        VStack(spacing: 20) {
                            // Title field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Title")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                
                                TextField("Enter memory title", text: $title)
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
                            
                            // Memory date
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Memory Date")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                
                                DatePicker("", selection: $memoryDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .colorScheme(.dark)
                                    .accentColor(Color(red: 0.9, green: 0.7, blue: 0.2))
                            }
                            
                            // Category picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(categories, id: \.self) { cat in
                                            Button(action: { category = cat }) {
                                                Text(cat.capitalized)
                                                    .font(.system(size: 14, weight: .medium, design: .serif))
                                                    .padding(.horizontal, 15)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .fill(category == cat ? Color(red: 0.9, green: 0.7, blue: 0.2) : Color.black.opacity(0.2))
                                                    )
                                                    .foregroundColor(category == cat ? .white : Color(red: 0.98, green: 0.97, blue: 0.95))
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            
                            // Content field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Memory Details")
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
                                    .frame(height: 120)
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                    .scrollContentBackground(.hidden)
                            }
                            
                            // Associated photo section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Associate with Photo (Optional)")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                
                                if let photo = selectedPhoto,
                                   let imagePath = photo.imagePath,
                                   let image = photoDataManager.loadImage(from: imagePath) {
                                    HStack {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Day \(photo.dayNumber)")
                                                .font(.system(size: 14, weight: .semibold, design: .serif))
                                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                            
                                            if let note = photo.personalNote, !note.isEmpty {
                                                Text(note)
                                                    .font(.system(size: 12, design: .serif))
                                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                                    .opacity(0.7)
                                                    .lineLimit(2)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Button("Remove") {
                                            selectedPhoto = nil
                                        }
                                        .font(.system(size: 12, weight: .medium, design: .serif))
                                        .foregroundColor(Color.red.opacity(0.8))
                                    }
                                    .padding(10)
                                    .background(Color.black.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Button(action: { showingPhotoPicker = true }) {
                                        HStack {
                                            Image(systemName: "photo")
                                                .font(.system(size: 16))
                                            Text("Choose Photo")
                                                .font(.system(size: 16, weight: .medium, design: .serif))
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.5), lineWidth: 1)
                                        )
                                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                    }
                                }
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
                            
                            Button("Save Memory") {
                                saveMemory()
                            }
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 0.9, green: 0.7, blue: 0.2))
                            )
                            .foregroundColor(.white)
                            .disabled(title.isEmpty || content.isEmpty)
                            .opacity((title.isEmpty || content.isEmpty) ? 0.6 : 1.0)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            photoDataManager.fetchPhotos()
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPickerView(
                photos: photoDataManager.photos,
                selectedPhoto: $selectedPhoto,
                isPresented: $showingPhotoPicker,
                photoDataManager: photoDataManager
            )
        }
    }
    
    private func saveMemory() {
        photoDataManager.saveMemory(
            title: title,
            content: content,
            date: memoryDate,
            category: category,
            associatedPhoto: selectedPhoto
        )
        
        onComplete()
        presentationMode.wrappedValue.dismiss()
    }
}

struct PhotoPickerView: View {
    let photos: [Photo]
    @Binding var selectedPhoto: Photo?
    @Binding var isPresented: Bool
    let photoDataManager: PhotoDataManager
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 10)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.075, green: 0.267, blue: 0.176)
                    .ignoresSafeArea(.all)
                
                VStack {
                    Text("Choose Photo")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                        .padding()
                    
                    if photos.isEmpty {
                        Spacer()
                        
                        VStack(spacing: 15) {
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                .opacity(0.5)
                            
                            Text("No photos available")
                                .font(.system(size: 18, weight: .medium, design: .serif))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                .opacity(0.7)
                        }
                        
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 15) {
                                ForEach(photos, id: \.id) { photo in
                                    Button(action: {
                                        selectedPhoto = photo
                                        isPresented = false
                                    }) {
                                        ZStack {
                                            if let imagePath = photo.imagePath,
                                               let image = photoDataManager.loadImage(from: imagePath) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                            } else {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.black.opacity(0.3))
                                                    .frame(width: 100, height: 100)
                                                    .overlay(
                                                        Image(systemName: "photo")
                                                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.5))
                                                    )
                                            }
                                            
                                            VStack {
                                                HStack {
                                                    Text("\(photo.dayNumber)")
                                                        .font(.system(size: 10, weight: .bold, design: .serif))
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(Color.black.opacity(0.7))
                                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                                    Spacer()
                                                }
                                                Spacer()
                                            }
                                            .padding(4)
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedPhoto?.id == photo.id ? Color(red: 0.9, green: 0.7, blue: 0.2) : Color.clear, lineWidth: 2)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            }
            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95)))
        }
    }
}

#Preview {
    AddMemoryView(photoDataManager: PhotoDataManager()) { }
}