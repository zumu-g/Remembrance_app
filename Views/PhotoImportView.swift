import SwiftUI
import PhotosUI

struct PhotoImportView: View {
    @StateObject private var photoViewModel = PhotoViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var errorHandler = ErrorHandler.shared
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var importedImages: [UIImage] = []
    @State private var isImporting = false
    @State private var importProgress: Double = 0.0
    @State private var progressMessage = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var validationErrors: [String] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                headerView
                
                if importedImages.isEmpty {
                    emptyStateView
                } else {
                    importedPhotosView
                }
                
                Spacer()
                
                if !importedImages.isEmpty {
                    importButton
                }
                
                BottomHomeButton()
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 365,
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("Select Multiple Photos")
                        }
                    }
                    .disabled(isImporting)
                }
            }
        }
        .onChange(of: selectedPhotos) {
            loadSelectedPhotos()
        }
        .alert("Import Result", isPresented: $showingAlert) {
            Button("OK") {
                if importedImages.count > 0 {
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
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Import Your Photos")
                .font(.title2)
                .fontWeight(.medium)
            
            VStack(spacing: 8) {
                Text("Select up to 365 photos to create your memorial collection")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("You can select multiple photos at once")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
            }
            .padding(.horizontal)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.6))
            
            Text("No photos selected")
                .font(.title3)
                .foregroundColor(.gray)
            
            Text("Tap 'Select Multiple Photos' to choose up to 365 memorial photos at once")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var importedPhotosView: some View {
        VStack(spacing: 16) {
            Text("Selected Photos: \(importedImages.count)")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 80))
                ], spacing: 8) {
                    ForEach(Array(importedImages.enumerated()), id: \.offset) { index, image in
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
                                            .font(.caption2)
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
            if importedImages.count < 365 {
                Text("Note: You have \(importedImages.count) photos. Photos will cycle through the year.")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                importPhotos()
            }) {
                Text("Import \(importedImages.count) Photos")
                    .font(.headline)
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
        Color.black.opacity(0.6)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        ProgressView(value: importProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: settingsViewModel.getThemeColor(for: .accent)))
                            .frame(width: 250)
                            .scaleEffect(1.2)
                        
                        Text(progressMessage.isEmpty ? "Importing Photos..." : progressMessage)
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("\(Int(importProgress * 100))% Complete")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    VStack(spacing: 8) {
                        Text("Processing and optimizing your photos")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("This may take a moment...")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.8))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                )
            )
    }
    
    private func loadSelectedPhotos() {
        importedImages.removeAll()
        
        Task {
            for item in selectedPhotos {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        importedImages.append(image)
                    }
                }
            }
        }
    }
    
    private func importPhotos() {
        guard !importedImages.isEmpty else { return }
        
        isImporting = true
        importProgress = 0.0
        progressMessage = "Preparing photos..."
        
        Task {
            do {
                let success = await photoViewModel.addPhotos(importedImages)
                
                await MainActor.run {
                    isImporting = false
                    
                    if success {
                        alertMessage = importedImages.count < 365 ? 
                            "Successfully imported \(importedImages.count) photos. Photos will cycle to fill all 365 days." :
                            "Successfully imported your complete memorial collection of 365 photos."
                    } else {
                        alertMessage = "Some photos could not be imported. Please check the error messages and try again."
                    }
                    
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isImporting = false
                    errorHandler.handle(error, context: "Photo import failed")
                }
            }
        }
    }
}

#Preview {
    PhotoImportView()
        .environmentObject(PhotoStore())
}