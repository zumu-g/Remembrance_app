import SwiftUI
import UniformTypeIdentifiers

struct FilesImportView: View {
    @StateObject private var photoViewModel = PhotoViewModel()
    @State private var isImporting = false
    @State private var showingFilePicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var importProgress: Double = 0.0
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                headerView
                
                if selectedImages.isEmpty {
                    filesPickerArea
                } else {
                    importedPhotosView
                }
                
                Spacer()
                
                if !selectedImages.isEmpty {
                    importButton
                }
            }
            .padding()
            .navigationTitle("Import from Files")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            handleFileImport(result: result)
        }
        .alert("Import Result", isPresented: $showingAlert) {
            Button("OK") {
                if selectedImages.count > 0 {
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
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Import from Files")
                    .serifFont(.serifTitle2)
                    .foregroundColor(.primary)
                
                Text("Browse your Files app to select memorial photos from iCloud, folders, or other storage locations.")
                    .serifFont(.serifBody)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var filesPickerArea: some View {
        PaperCardView {
            VStack(spacing: 24) {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(.blue.opacity(0.6))
                
                Text("Choose Photos from Files")
                    .serifFont(.serifTitle2)
                    .foregroundColor(.primary)
                
                Text("Access photos from iCloud Drive, Downloads, or any connected storage")
                    .serifFont(.serifBody)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Browse Files") {
                    showingFilePicker = true
                }
                .serifFont(.serifHeadline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 250)
        }
    }
    
    private var importedPhotosView: some View {
        VStack(spacing: 16) {
            Text("Selected Photos: \(selectedImages.count)")
                .serifFont(.serifHeadline)
                .foregroundColor(.primary)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 80))
                ], spacing: 8) {
                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
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
            if selectedImages.count < 365 {
                Text("Note: You have \(selectedImages.count) photos. Photos will cycle through the year.")
                    .serifFont(.serifCaption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                importPhotos()
            }) {
                Text("Import \(selectedImages.count) Photos")
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
    
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            selectedImages.removeAll()
            
            for url in urls {
                // Ensure we have access to the file
                guard url.startAccessingSecurityScopedResource() else { continue }
                defer { url.stopAccessingSecurityScopedResource() }
                
                if let imageData = try? Data(contentsOf: url),
                   let image = UIImage(data: imageData) {
                    selectedImages.append(image)
                }
            }
            
        case .failure(let error):
            alertMessage = "Error importing files: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func importPhotos() {
        guard !selectedImages.isEmpty else { return }
        
        isImporting = true
        importProgress = 0.0
        
        Task {
            let success = await photoViewModel.addPhotos(selectedImages)
            
            await MainActor.run {
                isImporting = false
                
                if success {
                    alertMessage = "Successfully imported \(selectedImages.count) photos to your memorial collection."
                } else {
                    alertMessage = "Some photos could not be imported. Please try again."
                }
                
                showingAlert = true
            }
        }
    }
}

#Preview {
    FilesImportView()
}