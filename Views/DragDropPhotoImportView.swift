import SwiftUI
import UniformTypeIdentifiers

struct DragDropPhotoImportView: View {
    @StateObject private var photoViewModel = PhotoViewModel()
    @State private var draggedImages: [UIImage] = []
    @State private var isImporting = false
    @State private var importProgress: Double = 0.0
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                headerView
                
                if draggedImages.isEmpty {
                    dragDropArea
                } else {
                    importedPhotosView
                }
                
                Spacer()
                
                if !draggedImages.isEmpty {
                    importButton
                }
            }
            .padding()
            .navigationTitle("Import Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Import Result", isPresented: $showingAlert) {
            Button("OK") {
                if draggedImages.count > 0 {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
        .overlay(
            Group {
                if isImporting {
                    importingOverlay
                }
            }
        )
    }
    
    private var headerView: some View {
        PaperCardView {
            VStack(spacing: 16) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Import Your Photos")
                    .serifFont(.serifTitle2)
                    .foregroundColor(.primary)
                
                Text("Drag and drop photos here, or use the Photos app to select up to 365 memorial photos.")
                    .serifFont(.serifBody)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var dragDropArea: some View {
        PaperCardView {
            VStack(spacing: 24) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 80))
                    .foregroundColor(.blue.opacity(0.6))
                
                Text("Drop Photos Here")
                    .serifFont(.serifTitle2)
                    .foregroundColor(.primary)
                
                Text("Drag photos from Files, Photos, or any other app")
                    .serifFont(.serifBody)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Divider()
                
                Text("Or use the traditional photo picker")
                    .serifFont(.serifCaption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
        }
        .onDrop(of: [UTType.image], isTargeted: nil) { providers in
            handleDrop(providers: providers)
            return true
        }
    }
    
    private var importedPhotosView: some View {
        VStack(spacing: 16) {
            Text("Selected Photos: \(draggedImages.count)")
                .serifFont(.serifHeadline)
                .foregroundColor(.primary)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 80))
                ], spacing: 8) {
                    ForEach(Array(draggedImages.enumerated()), id: \.offset) { index, image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(8)
                            .overlay(
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text("\(index + 1)")
                                            .serifFont(.serifCaption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(4)
                                            .background(Color.black.opacity(0.7))
                                            .clipShape(Circle())
                                    }
                                }
                                .padding(2)
                            )
                    }
                }
            }
            .frame(maxHeight: 300)
        }
    }
    
    private var importButton: some View {
        VStack(spacing: 12) {
            if draggedImages.count < 365 {
                Text("Note: You have \(draggedImages.count) photos. Photos will cycle through the year.")
                    .serifFont(.serifCaption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                importPhotos()
            }) {
                Text("Import \(draggedImages.count) Photos")
                    .serifFont(.serifHeadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .disabled(isImporting)
        }
    }
    
    private var importingOverlay: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 20) {
                    ProgressView(value: importProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 200)
                    
                    Text("Importing Photos...")
                        .serifFont(.serifHeadline)
                        .foregroundColor(.white)
                    
                    Text("\(Int(importProgress * 100))%")
                        .serifFont(.serifSubheadline)
                        .foregroundColor(.white)
                }
                .padding(30)
                .background(Color.black.opacity(0.8))
                .cornerRadius(16)
            )
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            draggedImages.append(image)
                        }
                    }
                }
            }
        }
    }
    
    private func importPhotos() {
        guard !draggedImages.isEmpty else { return }
        
        isImporting = true
        importProgress = 0.0
        
        Task {
            let success = await photoViewModel.addPhotos(draggedImages)
            
            await MainActor.run {
                isImporting = false
                
                if success {
                    alertMessage = "Successfully imported \(draggedImages.count) photos to your memorial collection."
                } else {
                    alertMessage = "Some photos could not be imported. Please try again."
                }
                
                showingAlert = true
            }
        }
    }
}

#Preview {
    DragDropPhotoImportView()
}