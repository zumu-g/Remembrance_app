import SwiftUI
import PhotosUI

struct MainPhotoImportView: View {
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var mainPhoto: UIImage?
    @State private var showingFilePicker = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                headerView
                
                if let mainPhoto = mainPhoto {
                    selectedPhotoView(image: mainPhoto)
                } else {
                    photoSelectionArea
                }
                
                Spacer()
                
                if mainPhoto != nil {
                    actionButtons
                }
                
                BottomHomeButton()
            }
            .padding()
            .navigationTitle("Set Main Portrait")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if mainPhoto != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveMainPhoto()
                        }
                        .serifFont(.serifBody)
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .onChange(of: selectedPhoto) {
            loadSelectedPhoto()
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result: result)
        }
    }
    
    private var headerView: some View {
        PaperCardView {
            VStack(spacing: 16) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.pink)
                
                Text("Choose Main Portrait")
                    .serifFont(.serifTitle2)
                    .foregroundColor(.primary)
                
                Text("Select a special photo of your mum to display on the home screen. This will be the first thing you see when you open the app.")
                    .serifFont(.serifBody)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var photoSelectionArea: some View {
        VStack(spacing: 20) {
            selectionMethodCard(
                icon: "photo.on.rectangle",
                title: "From Photos",
                description: "Select from your Photos app",
                action: { /* PhotosPicker handles this */ }
            )
            
            selectionMethodCard(
                icon: "folder",
                title: "From Files",
                description: "Browse Files app or iCloud Drive",
                action: { showingFilePicker = true }
            )
        }
        .overlay(
            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images
            ) {
                Color.clear
            }
        )
    }
    
    private func selectionMethodCard(
        icon: String,
        title: String,
        description: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            PaperCardView {
                HStack(spacing: 16) {
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                        .frame(width: 60)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .serifFont(.serifHeadline)
                            .foregroundColor(.primary)
                        
                        Text(description)
                            .serifFont(.serifBody)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func selectedPhotoView(image: UIImage) -> some View {
        VStack(spacing: 20) {
            Text("Selected Portrait")
                .serifFont(.serifHeadline)
                .foregroundColor(.primary)
            
            PaperCardView {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
            }
            
            Text("This beautiful photo will be displayed on your home screen")
                .serifFont(.serifBody)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button("Choose Different Photo") {
                mainPhoto = nil
                selectedPhoto = nil
            }
            .serifFont(.serifBody)
            .foregroundColor(.blue)
            
            Button("Save as Main Portrait") {
                saveMainPhoto()
            }
            .serifFont(.serifHeadline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.pink)
            .cornerRadius(12)
        }
    }
    
    private func loadSelectedPhoto() {
        guard let selectedPhoto = selectedPhoto else { return }
        
        Task {
            if let data = try? await selectedPhoto.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    mainPhoto = image
                }
            }
        }
    }
    
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Ensure we have access to the file
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            if let imageData = try? Data(contentsOf: url),
               let image = UIImage(data: imageData) {
                mainPhoto = image
            }
            
        case .failure(let error):
            print("Error importing file: \(error)")
        }
    }
    
    private func saveMainPhoto() {
        guard let mainPhoto = mainPhoto else { return }
        
        // Save to UserDefaults for now (in a real app, you'd save to Core Data)
        if let imageData = mainPhoto.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "mainPortraitPhoto")
        }
        
        dismiss()
    }
}

#Preview {
    MainPhotoImportView()
}