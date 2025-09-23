import Foundation
import CoreData
import UIKit

class PhotoDataManager: ObservableObject {
    private let persistenceController = PersistenceController.shared
    @Published var photos: [Photo] = []
    @Published var todayPhoto: Photo?
    
    init() {
        fetchPhotos()
        fetchTodayPhoto()
    }
    
    func fetchPhotos() {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Photo.dayNumber, ascending: true)]
        
        do {
            photos = try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error fetching photos: \(error)")
        }
    }
    
    func fetchTodayPhoto() {
        let calendarManager = CalendarManager()
        let currentDay = calendarManager.currentDay
        
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "dayNumber == %d", currentDay)
        request.fetchLimit = 1
        
        do {
            let results = try persistenceController.container.viewContext.fetch(request)
            todayPhoto = results.first
        } catch {
            print("Error fetching today's photo: \(error)")
        }
    }
    
    func savePhoto(_ image: UIImage, for day: Int, with note: String = "") {
        let photoCaptureManager = PhotoCaptureManager()
        
        guard let fileName = photoCaptureManager.saveImageToDocuments(image) else {
            print("Failed to save image to documents")
            return
        }
        
        // Check if photo already exists for this day
        let existingPhotoRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        existingPhotoRequest.predicate = NSPredicate(format: "dayNumber == %d", day)
        existingPhotoRequest.fetchLimit = 1
        
        let context = persistenceController.container.viewContext
        
        do {
            let existingPhotos = try context.fetch(existingPhotoRequest)
            let photo = existingPhotos.first ?? Photo(context: context)
            
            photo.id = photo.id ?? UUID()
            photo.dayNumber = Int32(day)
            photo.imagePath = fileName
            photo.personalNote = note
            photo.dateAdded = Date()
            photo.assignedDate = CalendarManager().getDateForDay(day)
            photo.isFavorite = false
            photo.isViewed = true
            
            try context.save()
            
            DispatchQueue.main.async {
                self.fetchPhotos()
                self.fetchTodayPhoto()
                
                // Mark day as completed
                let calendarManager = CalendarManager()
                calendarManager.markDayCompleted(day)
            }
            
        } catch {
            print("Error saving photo: \(error)")
        }
    }
    
    func updatePhotoNote(for photo: Photo, note: String) {
        photo.personalNote = note
        saveContext()
        fetchPhotos()
    }
    
    func togglePhotoFavorite(for photo: Photo) {
        photo.isFavorite.toggle()
        saveContext()
        fetchPhotos()
    }
    
    func deletePhoto(_ photo: Photo) {
        // Delete image file
        if let imagePath = photo.imagePath {
            deleteImageFromDocuments(imagePath)
        }
        
        // Delete from Core Data
        persistenceController.container.viewContext.delete(photo)
        saveContext()
        fetchPhotos()
        fetchTodayPhoto()
    }
    
    private func deleteImageFromDocuments(_ fileName: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error deleting image file: \(error)")
        }
    }
    
    func getPhoto(for day: Int) -> Photo? {
        return photos.first { $0.dayNumber == day }
    }
    
    func getPhotosByFavorites() -> [Photo] {
        return photos.filter { $0.isFavorite }
    }
    
    func getPhotosForMonth(_ month: Int, year: Int) -> [Photo] {
        let calendar = Calendar.current
        return photos.filter { photo in
            guard let date = photo.assignedDate else { return false }
            let components = calendar.dateComponents([.month, .year], from: date)
            return components.month == month && components.year == year
        }
    }
    
    func getCompletionStats() -> (completed: Int, total: Int, percentage: Double) {
        let completed = photos.count
        let total = 365
        let percentage = Double(completed) / Double(total) * 100.0
        return (completed, total, percentage)
    }
    
    private func saveContext() {
        do {
            try persistenceController.container.viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // Load image from documents directory
    func loadImage(from fileName: String?) -> UIImage? {
        guard let fileName = fileName else { return nil }
        let photoCaptureManager = PhotoCaptureManager()
        return photoCaptureManager.loadImageFromDocuments(fileName)
    }
}

// MARK: - Memory Management
extension PhotoDataManager {
    func saveMemory(title: String, content: String, date: Date? = nil, category: String = "general", associatedPhoto: Photo? = nil) {
        let context = persistenceController.container.viewContext
        let memory = Memory(context: context)
        
        memory.id = UUID()
        memory.title = title
        memory.content = content
        memory.dateCreated = Date()
        memory.memoryDate = date ?? Date()
        memory.category = category
        memory.isSpecialDate = (category == "special")
        memory.associatedPhoto = associatedPhoto
        
        saveContext()
    }
    
    func fetchMemories() -> [Memory] {
        let request: NSFetchRequest<Memory> = Memory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Memory.dateCreated, ascending: false)]
        
        do {
            return try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error fetching memories: \(error)")
            return []
        }
    }
    
    func saveTribute(title: String, message: String, authorName: String = "", isPublic: Bool = false) {
        let context = persistenceController.container.viewContext
        let tribute = Tribute(context: context)
        
        tribute.id = UUID()
        tribute.title = title
        tribute.message = message
        tribute.authorName = authorName
        tribute.dateCreated = Date()
        tribute.isPublic = isPublic
        
        saveContext()
    }
    
    func fetchTributes() -> [Tribute] {
        let request: NSFetchRequest<Tribute> = Tribute.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Tribute.dateCreated, ascending: false)]
        
        do {
            return try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error fetching tributes: \(error)")
            return []
        }
    }
}