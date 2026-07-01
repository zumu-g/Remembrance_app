import SwiftUI

struct DailyPhotoView: View {
    @ObservedObject private var photoManager = PhotoManager.shared
    @StateObject private var quoteViewModel = QuoteViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var errorHandler = ErrorHandler.shared
    @State private var showingFullScreen = false
    @State private var showingNoteEditor = false
    @State private var noteText = ""
    @State private var showingPhotoImport = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with gradient theme support
                settingsViewModel.getGradientBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    headerView
                    
                    if photoManager.currentPhoto != nil {
                        photoDisplayView(geometry: geometry)
                        quoteView
                        controlsView
                    } else {
                        noPhotoView
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            Task {
                print("DailyPhotoView appeared - loading today's content")
                print("DEBUG DailyPhotoView: PhotoManager.shared instance ID: \(ObjectIdentifier(PhotoManager.shared))")
                
                photoManager.loadTodaysPhoto()
                await quoteViewModel.loadTodaysQuote()
                
                print("Photo loaded: \(photoManager.currentPhoto != nil)")
                print("Quote loaded: \(quoteViewModel.hasCurrentQuote())")
                print("Total photos: \(photoManager.allPhotos.count)")
                print("Total quotes: \(quoteViewModel.getQuotesCount())")
                
                if let photo = photoManager.currentPhoto {
                    noteText = photo.personalNote ?? ""
                }
            }
        }
        .onChange(of: photoManager.currentPhoto) {
            if let photo = photoManager.currentPhoto {
                photoManager.markPhotoAsViewed(photo)
                noteText = photo.personalNote ?? ""
            }
        }
        .sheet(isPresented: $showingNoteEditor) {
            noteEditorView
        }
        .sheet(isPresented: $showingPhotoImport) {
            PhotoImportView()
        }
        .fullScreenCover(isPresented: $showingFullScreen) {
            if photoManager.currentPhoto != nil {
                fullScreenPhotoView
            }
        }
        .alert("Error", isPresented: $errorHandler.showErrorAlert) {
            Button("OK") {
                errorHandler.clearError()
            }
            Button("Retry") {
                errorHandler.clearError()
                photoManager.loadTodaysPhoto()
            }
        } message: {
            Text(errorHandler.currentError?.message ?? "An unknown error occurred")
        }
        .refreshable {
            Task {
                photoManager.loadPhotos()
                photoManager.loadTodaysPhoto()
                await quoteViewModel.refreshQuotes()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshTodaysPhoto)) { _ in
            photoManager.loadPhotos()
            photoManager.loadTodaysPhoto()
        }
        .onReceive(NotificationCenter.default.publisher(for: .photosUpdated)) { _ in
            print("DailyPhotoView received photosUpdated notification - refreshing data")
            Task {
                photoManager.loadPhotos()
                photoManager.loadTodaysPhoto()
                await quoteViewModel.refreshQuotes()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Today's Memory")
                .font(.largeTitle.weight(.light))
                .foregroundColor(settingsViewModel.getThemeColor(for: .primary))
                .scaleEffect(settingsViewModel.fontSize.scaleFactor)
            
            Text(photoManager.allPhotos.count > 0 ? "\(photoManager.allPhotos.count) memories in collection" : "Add photos to begin")
                .font(.headline)
                .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
            
            if let date = photoManager.currentPhoto?.assignedDate {
                Text(date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: settingsViewModel.getThemeColor(for: .accent)))
            
            Text("Loading today's memory...")
                .font(.headline)
                .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
        }
    }
    
    private var progressIndicatorView: some View {
        VStack(spacing: 8) {
            ProgressView(value: Double(photoManager.allPhotos.count) / 365.0)
                .progressViewStyle(LinearProgressViewStyle(tint: settingsViewModel.getThemeColor(for: .accent)))
                .frame(height: 8)
            
            Text("Progress: \(photoManager.allPhotos.count) of 365 photos")
                .font(.caption)
                .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
        }
        .padding(.horizontal)
    }
    
    private func photoDisplayView(geometry: GeometryProxy) -> some View {
        VStack {
            if let photo = photoManager.currentPhoto,
               let imagePath = photo.imagePath,
               let image = photoManager.loadImageFromDocuments(filename: imagePath) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: geometry.size.width * 0.9)
                    .frame(maxHeight: geometry.size.height * 0.5)
                    .cornerRadius(12)
                    .shadow(color: settingsViewModel.getThemeColor(for: .accent).opacity(0.3), radius: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(settingsViewModel.getThemeColor(for: .accent).opacity(0.2), lineWidth: 1)
                    )
                    .onTapGesture {
                        showingFullScreen = true
                    }
                    .contextMenu {
                        Button(action: {
                            if let photo = photoManager.currentPhoto {
                                photoManager.toggleFavorite(photo)
                            }
                        }) {
                            Label(
                                (photoManager.currentPhoto?.isFavorite ?? false) ? "Remove from Favorites" : "Add to Favorites",
                                systemImage: (photoManager.currentPhoto?.isFavorite ?? false) ? "heart.slash" : "heart"
                            )
                        }
                        
                        Button(action: {
                            showingNoteEditor = true
                        }) {
                            Label("Add Note", systemImage: "note.text")
                        }
                        
                        Button(action: {
                            showingFullScreen = true
                        }) {
                            Label("View Full Screen", systemImage: "arrow.up.left.and.arrow.down.right")
                        }
                    }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(settingsViewModel.getThemeColor(for: .secondary).opacity(0.1))
                    .frame(height: geometry.size.height * 0.4)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
                            Text("Photo not available")
                                .font(.headline)
                                .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
                        }
                    )
            }
        }
    }
    
    private var controlsView: some View {
        HStack(spacing: 30) {
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    if let photo = photoManager.currentPhoto {
                        photoManager.toggleFavorite(photo)
                    }
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: (photoManager.currentPhoto?.isFavorite ?? false) ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor((photoManager.currentPhoto?.isFavorite ?? false) ? .red : settingsViewModel.getThemeColor(for: .secondary))
                        .scaleEffect((photoManager.currentPhoto?.isFavorite ?? false) ? 1.1 : 1.0)
                    
                    Text("Favorite")
                        .font(.caption2)
                        .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
                }
            }
            
            Button(action: {
                showingNoteEditor = true
            }) {
                VStack(spacing: 4) {
                    Image(systemName: (photoManager.currentPhoto?.personalNote?.isEmpty ?? true) ? "note.text" : "note.text.badge.plus")
                        .font(.title2)
                        .foregroundColor(settingsViewModel.getThemeColor(for: .accent))
                    
                    Text("Note")
                        .font(.caption2)
                        .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
                }
            }
            
            Button(action: {
                showingFullScreen = true
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.title2)
                        .foregroundColor(settingsViewModel.getThemeColor(for: .accent))
                    
                    Text("Full View")
                        .font(.caption2)
                        .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(settingsViewModel.getThemeColor(for: .background))
                .shadow(color: settingsViewModel.getThemeColor(for: .accent).opacity(0.1), radius: 8)
        )
    }
    
    private var noPhotoView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 80))
                    .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
                
                Text("No photos available")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(settingsViewModel.getThemeColor(for: .primary))
                
                Text("Add photos to your memorial collection to begin")
                    .font(.body)
                    .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
                    .multilineTextAlignment(.center)
            }
            
            // Show quote even when no photos
            quoteView
            
            VStack(spacing: 12) {
                Button(action: {
                    showingPhotoImport = true
                }) {
                    Label("Import Photos", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(settingsViewModel.getThemeColor(for: .accent))
                        .cornerRadius(12)
                }
                
                Text("Import your photos to create a beautiful memorial collection")
                    .font(.caption)
                    .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
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
                        if let photo = photoManager.currentPhoto {
                            photoManager.updatePersonalNote(photo, note: noteText)
                        }
                        showingNoteEditor = false
                    }
                }
            }
        }
    }
    
    private var fullScreenPhotoView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button("Done") {
                        showingFullScreen = false
                    }
                    .foregroundColor(.white)
                    .padding()
                }
                
                Spacer()
                
                if let photo = photoManager.currentPhoto,
                   let imagePath = photo.imagePath,
                   let image = photoManager.loadImageFromDocuments(filename: imagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
                
                Spacer()
            }
        }
    }
    
    private var quoteView: some View {
        VStack(spacing: 12) {
            if quoteViewModel.hasCurrentQuote() {
                VStack(spacing: 8) {
                    Text(quoteViewModel.getQuoteText())
                        .font(.body)
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundColor(settingsViewModel.getThemeColor(for: .primary))
                        .scaleEffect(settingsViewModel.fontSize.scaleFactor)
                        .lineLimit(nil)
                    
                    Text(quoteViewModel.getQuoteAuthor())
                        .font(.caption)
                        .foregroundColor(settingsViewModel.getThemeColor(for: .secondary))
                        .scaleEffect(settingsViewModel.fontSize.scaleFactor)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(settingsViewModel.getThemeColor(for: .accent).opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(settingsViewModel.getThemeColor(for: .accent).opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: settingsViewModel.getThemeColor(for: .accent).opacity(0.1), radius: 4)
            }
        }
        .padding(.horizontal)
    }
    
    private var backgroundColor: Color {
        Color(UIColor.systemBackground)
    }
}

#Preview {
    DailyPhotoView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}