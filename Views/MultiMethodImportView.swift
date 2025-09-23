import SwiftUI

struct MultiMethodImportView: View {
    @State private var showingPhotosImport = false
    @State private var showingFilesImport = false
    @State private var showingDragDropImport = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                headerView
                
                VStack(spacing: 20) {
                    importMethodCard(
                        icon: "folder.badge.plus",
                        title: "Files App",
                        description: "Browse iCloud Drive, Downloads, or any storage location",
                        recommendation: "Recommended for organized users",
                        color: .blue,
                        action: { showingFilesImport = true }
                    )
                    
                    importMethodCard(
                        icon: "photo.on.rectangle.angled",
                        title: "Photos Library",
                        description: "Select from your device's Photos app",
                        recommendation: "Simple and familiar",
                        color: .green,
                        action: { showingPhotosImport = true }
                    )
                    
                    importMethodCard(
                        icon: "square.and.arrow.down",
                        title: "Drag & Drop",
                        description: "Drag photos from any app or location",
                        recommendation: "Great for iPad and Mac",
                        color: .orange,
                        action: { showingDragDropImport = true }
                    )
                }
                
                Spacer()
                
                preparationTips
            }
            .padding()
            .navigationTitle("Import Memorial Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingPhotosImport) {
            PhotoImportView()
        }
        .sheet(isPresented: $showingFilesImport) {
            FilesImportView()
        }
        .sheet(isPresented: $showingDragDropImport) {
            DragDropPhotoImportView()
        }
    }
    
    private var headerView: some View {
        PaperCardView {
            VStack(spacing: 16) {
                Image(systemName: "heart.text.square")
                    .font(.system(size: 60))
                    .foregroundColor(.pink)
                
                Text("Add Your Memorial Photos")
                    .serifFont(.serifTitle2)
                    .foregroundColor(.primary)
                
                Text("Choose the method that works best for you to import your precious memories.")
                    .serifFont(.serifBody)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private func importMethodCard(
        icon: String,
        title: String,
        description: String,
        recommendation: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            PaperCardView {
                HStack(spacing: 16) {
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundColor(color)
                        .frame(width: 60)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .serifFont(.serifHeadline)
                            .foregroundColor(.primary)
                        
                        Text(description)
                            .serifFont(.serifBody)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        
                        Text(recommendation)
                            .serifFont(.serifCaption)
                            .foregroundColor(color)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var preparationTips: some View {
        PaperCardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 16))
                        .foregroundColor(.yellow)
                    
                    Text("Preparation Tips")
                        .serifFont(.serifHeadline)
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    tipRow("Organize photos in a folder before importing")
                    tipRow("Name files chronologically if you have specific dates")
                    tipRow("You can import in batches if you have many photos")
                    tipRow("Photos will cycle through the year if you have less than 365")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .serifFont(.serifBody)
                .foregroundColor(.secondary)
            
            Text(text)
                .serifFont(.serifCaption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    MultiMethodImportView()
}