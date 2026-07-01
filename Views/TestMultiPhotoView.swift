import SwiftUI
import PhotosUI

struct TestMultiPhotoView: View {
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Multi-Photo Selection Test")
                    .font(.title)
                
                Text("Selected: \(selectedPhotos.count) photos")
                    .font(.headline)
                
                Text("Loaded: \(loadedImages.count) images")
                    .font(.headline)
                
                if !loadedImages.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                            ForEach(Array(loadedImages.enumerated()), id: \.offset) { index, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(8)
                                    .overlay(
                                        Text("\(index + 1)")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(4)
                                            .background(Color.black.opacity(0.7))
                                            .clipShape(Circle())
                                        , alignment: .topTrailing
                                    )
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Photo Test")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 10,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            Image(systemName: "photo.stack")
                            Text("Select Multiple")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .onChange(of: selectedPhotos) {
            print("TestMultiPhotoView: Selected \(selectedPhotos.count) photos")
            loadImages()
        }
    }
    
    private func loadImages() {
        loadedImages.removeAll()
        
        Task {
            for (index, item) in selectedPhotos.enumerated() {
                print("Loading image \(index + 1) of \(selectedPhotos.count)")
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        loadedImages.append(image)
                        print("Successfully loaded image \(loadedImages.count)")
                    }
                } else {
                    print("Failed to load image \(index + 1)")
                }
            }
        }
    }
}

#Preview {
    TestMultiPhotoView()
}