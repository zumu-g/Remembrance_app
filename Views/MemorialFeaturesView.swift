import SwiftUI

struct MemorialFeaturesView: View {
    @StateObject private var photoDataManager = PhotoDataManager()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Green background
            Color(red: 0.075, green: 0.267, blue: 0.176)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 10) {
                    Text("MEMORIAL")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                    
                    Text("Cherished memories and loving tributes")
                        .font(.system(size: 16, weight: .regular, design: .serif))
                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                        .opacity(0.8)
                }
                .padding(.vertical, 20)
                
                // Tab selector
                HStack(spacing: 0) {
                    TabButton(title: "Memories", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    
                    TabButton(title: "Special Dates", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    
                    TabButton(title: "Tributes", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Content
                Group {
                    switch selectedTab {
                    case 0:
                        MemoriesView(photoDataManager: photoDataManager)
                    case 1:
                        SpecialDatesView(photoDataManager: photoDataManager)
                    case 2:
                        TributesView(photoDataManager: photoDataManager)
                    default:
                        MemoriesView(photoDataManager: photoDataManager)
                    }
                }
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(isSelected ? Color(red: 0.9, green: 0.7, blue: 0.2) : Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.7))
                
                Rectangle()
                    .fill(isSelected ? Color(red: 0.9, green: 0.7, blue: 0.2) : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct MemoriesView: View {
    let photoDataManager: PhotoDataManager
    @State private var memories: [Memory] = []
    @State private var showingAddMemory = false
    
    var body: some View {
        VStack {
            // Add memory button
            HStack {
                Spacer()
                Button(action: { showingAddMemory = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                        Text("Add Memory")
                            .font(.system(size: 16, weight: .medium, design: .serif))
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.9, green: 0.7, blue: 0.2))
                    )
                    .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            
            // Memories list
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(memories, id: \.id) { memory in
                        MemoryCard(memory: memory, photoDataManager: photoDataManager)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .onAppear {
            loadMemories()
        }
        .sheet(isPresented: $showingAddMemory) {
            AddMemoryView(photoDataManager: photoDataManager) {
                loadMemories()
            }
        }
    }
    
    private func loadMemories() {
        memories = photoDataManager.fetchMemories().filter { !($0.isSpecialDate) }
    }
}

struct MemoryCard: View {
    let memory: Memory
    let photoDataManager: PhotoDataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    if let title = memory.title, !title.isEmpty {
                        Text(title)
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                    }
                    
                    if let memoryDate = memory.memoryDate {
                        Text(formatDate(memoryDate))
                            .font(.system(size: 14, weight: .regular, design: .serif))
                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                            .opacity(0.7)
                    }
                }
                
                Spacer()
                
                if let category = memory.category {
                    Text(category.capitalized)
                        .font(.system(size: 12, weight: .medium, design: .serif))
                        .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.2))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 0.9, green: 0.7, blue: 0.2).opacity(0.2))
                        )
                }
            }
            
            if let content = memory.content, !content.isEmpty {
                Text(content)
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                    .lineLimit(nil)
            }
            
            // Associated photo
            if let associatedPhoto = memory.associatedPhoto,
               let imagePath = associatedPhoto.imagePath,
               let image = photoDataManager.loadImage(from: imagePath) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct SpecialDatesView: View {
    let photoDataManager: PhotoDataManager
    @State private var specialDates: [Memory] = []
    @State private var showingAddSpecialDate = false
    
    var body: some View {
        VStack {
            // Add special date button
            HStack {
                Spacer()
                Button(action: { showingAddSpecialDate = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                        Text("Add Special Date")
                            .font(.system(size: 16, weight: .medium, design: .serif))
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.9, green: 0.7, blue: 0.2))
                    )
                    .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            
            // Special dates list
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(specialDates, id: \.id) { specialDate in
                        SpecialDateCard(memory: specialDate, photoDataManager: photoDataManager)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .onAppear {
            loadSpecialDates()
        }
        .sheet(isPresented: $showingAddSpecialDate) {
            AddSpecialDateView(photoDataManager: photoDataManager) {
                loadSpecialDates()
            }
        }
    }
    
    private func loadSpecialDates() {
        specialDates = photoDataManager.fetchMemories().filter { $0.isSpecialDate }
    }
}

struct SpecialDateCard: View {
    let memory: Memory
    let photoDataManager: PhotoDataManager
    
    var body: some View {
        HStack(spacing: 15) {
            // Date circle
            VStack(spacing: 2) {
                if let date = memory.memoryDate {
                    let day = Calendar.current.component(.day, from: date)
                    let month = Calendar.current.component(.month, from: date)
                    
                    Text(monthAbbreviation(month))
                        .font(.system(size: 12, weight: .semibold, design: .serif))
                        .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.2))
                    
                    Text("\(day)")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                }
            }
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        Circle()
                            .stroke(Color(red: 0.9, green: 0.7, blue: 0.2), lineWidth: 2)
                    )
            )
            
            // Content
            VStack(alignment: .leading, spacing: 5) {
                if let title = memory.title, !title.isEmpty {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                }
                
                if let content = memory.content, !content.isEmpty {
                    Text(content)
                        .font(.system(size: 14, weight: .regular, design: .serif))
                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                        .opacity(0.8)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func monthAbbreviation(_ month: Int) -> String {
        let months = ["", "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                     "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
        return months[month]
    }
}

struct TributesView: View {
    let photoDataManager: PhotoDataManager
    @State private var tributes: [Tribute] = []
    @State private var showingAddTribute = false
    
    var body: some View {
        VStack {
            // Add tribute button
            HStack {
                Spacer()
                Button(action: { showingAddTribute = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                        Text("Add Tribute")
                            .font(.system(size: 16, weight: .medium, design: .serif))
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.9, green: 0.7, blue: 0.2))
                    )
                    .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            
            // Tributes list
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(tributes, id: \.id) { tribute in
                        TributeCard(tribute: tribute)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .onAppear {
            loadTributes()
        }
        .sheet(isPresented: $showingAddTribute) {
            AddTributeView(photoDataManager: photoDataManager) {
                loadTributes()
            }
        }
    }
    
    private func loadTributes() {
        tributes = photoDataManager.fetchTributes()
    }
}

struct TributeCard: View {
    let tribute: Tribute
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if let title = tribute.title, !title.isEmpty {
                        Text(title)
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                    }
                    
                    HStack {
                        if let author = tribute.authorName, !author.isEmpty {
                            Text("by \(author)")
                                .font(.system(size: 14, weight: .regular, design: .serif))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                .opacity(0.7)
                        }
                        
                        if tribute.isPublic {
                            Image(systemName: "globe")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.2))
                        }
                    }
                }
                
                Spacer()
                
                if let dateCreated = tribute.dateCreated {
                    Text(formatDateShort(dateCreated))
                        .font(.system(size: 12, weight: .regular, design: .serif))
                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                        .opacity(0.6)
                }
            }
            
            if let message = tribute.message, !message.isEmpty {
                Text(message)
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                    .lineLimit(nil)
                    .italic()
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }
}

#Preview {
    MemorialFeaturesView()
}