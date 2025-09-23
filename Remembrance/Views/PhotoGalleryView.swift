import SwiftUI

struct PhotoGalleryView: View {
    @ObservedObject private var photoManager = PhotoManager.shared
    @State private var selectedPhoto: Photo?
    @State private var showingFullScreen = false
    @State private var showingFavoritesOnly = false
    @State private var showingStorageInfo = false
    @State private var showingPhotoImport = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    var filteredPhotos: [Photo] {
        let allPhotos = photoManager.allPhotos
        
        if showingFavoritesOnly {
            return allPhotos.filter { $0.isFavorite }
        }
        return allPhotos
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Add gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.85, green: 0.98, blue: 0.92),
                        Color(red: 0.92, green: 0.98, blue: 0.95),
                        Color(red: 0.88, green: 0.96, blue: 0.90)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    if filteredPhotos.isEmpty {
                        emptyStateView
                    } else {
                        photoGridView
                    }
                }
            }
            .navigationTitle("Memories")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingStorageInfo = true
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            photoManager.loadPhotos()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.orange)
                        }
                        
                        Button(action: {
                            showingPhotoImport = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            showingFavoritesOnly.toggle()
                        }) {
                            Image(systemName: showingFavoritesOnly ? "heart.fill" : "heart")
                                .foregroundColor(showingFavoritesOnly ? .red : .blue)
                        }
                    }
                }
            }
        }
        .onAppear {
            photoManager.loadPhotos()
        }
        .onReceive(NotificationCenter.default.publisher(for: .photosUpdated)) { _ in
            DispatchQueue.main.async {
                photoManager.loadPhotos()
            }
        }
        .refreshable {
            photoManager.loadPhotos()
        }
        .sheet(item: $selectedPhoto) { photo in
            PhotoDetailView(photo: photo, photoManager: photoManager)
        }
        .sheet(isPresented: $showingStorageInfo) {
            StorageInfoView(photoManager: photoManager)
        }
        .sheet(isPresented: $showingPhotoImport) {
            PhotoImportView()
        }
    }
    
    private var photoGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filteredPhotos, id: \.id) { photo in
                    PhotoGridItem(photo: photo, photoManager: photoManager)
                        .onTapGesture {
                            selectedPhoto = photo
                        }
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: showingFavoritesOnly ? "heart.slash" : "photo.on.rectangle")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text(showingFavoritesOnly ? "No favorite memories yet" : "No photos added yet")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text(showingFavoritesOnly ? "Mark photos as favorites to see them here" : "Add photos to start building your memorial collection")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if !showingFavoritesOnly {
                Button(action: {
                    showingPhotoImport = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Photos")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
        }
        .padding()
    }
}

struct PhotoGridItem: View {
    let photo: Photo
    let photoManager: PhotoManager
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if let imagePath = photo.imagePath,
                   let image = photoManager.loadImageFromDocuments(filename: imagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 150)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                }
                
                VStack {
                    HStack {
                        Spacer()
                        if photo.isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                    
                    HStack {
                        if !photo.isViewed {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                        }
                        Spacer()
                    }
                }
                .padding(8)
            }
            
            VStack(spacing: 4) {
                Text("Day \(photo.dayNumber)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let date = photo.assignedDate {
                    Text(date, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct PhotoDetailView: View {
    let photo: Photo
    let photoManager: PhotoManager
    @Environment(\.dismiss) private var dismiss
    @State private var noteText: String = ""
    @State private var showingNoteEditor = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let imagePath = photo.imagePath,
                   let image = photoManager.loadImageFromDocuments(filename: imagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .shadow(radius: 8)
                        .padding()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 300)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                        .padding()
                }
                
                VStack(spacing: 16) {
                    Text("Day \(photo.dayNumber) of 365")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    if let date = photo.assignedDate {
                        Text(date, style: .date)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let note = photo.personalNote, !note.isEmpty {
                        ScrollView {
                            Text(note)
                                .font(.body)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .frame(maxHeight: 100)
                    }
                }
                
                HStack(spacing: 30) {
                    Button(action: {
                        photoManager.toggleFavorite(photo)
                    }) {
                        VStack {
                            Image(systemName: photo.isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(photo.isFavorite ? .red : .gray)
                            Text("Favorite")
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        noteText = photo.personalNote ?? ""
                        showingNoteEditor = true
                    }) {
                        VStack {
                            Image(systemName: "note.text")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("Note")
                                .font(.caption)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingNoteEditor) {
            noteEditorView
        }
        .onAppear {
            if !photo.isViewed {
                photoManager.markPhotoAsViewed(photo)
            }
        }
    }
    
    private var noteEditorView: some View {
        NavigationView {
            VStack {
                TextEditor(text: $noteText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Memory Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingNoteEditor = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        photoManager.updatePersonalNote(photo, note: noteText)
                        showingNoteEditor = false
                    }
                }
            }
        }
    }
}

struct StorageInfoView: View {
    let photoManager: PhotoManager
    @Environment(\.dismiss) private var dismiss
    @State private var storageStatus: (totalPhotos: Int, filesInDocuments: Int, missingFiles: Int) = (0, 0, 0)
    @State private var isRunningIntegrityCheck = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Photo Storage Status")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Total Photos in Database:")
                            Spacer()
                            Text("\(storageStatus.totalPhotos)")
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Image Files in Storage:")
                            Spacer()
                            Text("\(storageStatus.filesInDocuments)")
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Missing Files:")
                            Spacer()
                            Text("\(storageStatus.missingFiles)")
                                .fontWeight(.medium)
                                .foregroundColor(storageStatus.missingFiles > 0 ? .red : .green)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    if storageStatus.missingFiles > 0 {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Some photos are missing their image files")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("All photos are properly stored")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                VStack(spacing: 16) {
                    Text("Storage Maintenance")
                        .font(.headline)
                    
                    Button(action: {
                        runIntegrityCheck()
                    }) {
                        HStack {
                            if isRunningIntegrityCheck {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "wrench.and.screwdriver")
                            }
                            Text(isRunningIntegrityCheck ? "Checking..." : "Verify & Repair Storage")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(isRunningIntegrityCheck)
                    
                    Text("This will check all photos and clean up any corrupted or missing files")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Storage Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            updateStorageStatus()
        }
    }
    
    private func updateStorageStatus() {
        storageStatus = photoManager.getStorageStatus()
    }
    
    private func runIntegrityCheck() {
        isRunningIntegrityCheck = true
        
        DispatchQueue.global(qos: .background).async {
            photoManager.verifyAndRepairPhotoStorage()
            
            DispatchQueue.main.async {
                updateStorageStatus()
                isRunningIntegrityCheck = false
            }
        }
    }
}

#Preview {
    PhotoGalleryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}