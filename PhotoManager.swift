import Foundation
import CoreData
import UIKit
import SwiftUI
import os.log

extension Notification.Name {
    static let photosUpdated = Notification.Name("photosUpdated")
    static let refreshTodaysPhoto = Notification.Name("refreshTodaysPhoto")
}

class PhotoManager: ObservableObject {
    static let shared = PhotoManager()
    
    private let persistenceController = PersistenceController.shared
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    private init() {
        // Load photos first, then verify
        loadPhotos()
        loadTodaysPhoto()
        // Delay verification to ensure Core Data is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.verifyAndRepairPhotoStorage()
        }
    }
    
    
    @Published var currentPhoto: Photo?
    @Published var allPhotos: [Photo] = []
    
    // Store today's selected photo persistently
    @AppStorage("todaysPhotoId") private var todaysPhotoId: String = ""
    @AppStorage("todaysPhotoDate") private var todaysPhotoDate: String = ""
    
    
    func loadPhotos() {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dayNumber", ascending: true)]
        
        // Force refresh the context to get latest data
        viewContext.refreshAllObjects()
        
        do {
            let fetchedPhotos = try viewContext.fetch(request)
            logPhotoOperation("loadPhotos", details: "Fetched \(fetchedPhotos.count) photos from Core Data")
            
            // Log each photo for debugging
            for photo in fetchedPhotos {
                logPhotoOperation("loadPhotos", details: "Photo day \(photo.dayNumber): \(photo.imagePath ?? "no path")")
            }
            
            // Force the update on the main thread
            DispatchQueue.main.async {
                self.allPhotos = fetchedPhotos
                self.logPhotoOperation("loadPhotos", details: "Updated allPhotos array with \(fetchedPhotos.count) photos")
            }
        } catch {
            logPhotoError("loadPhotos", error: error)
            ErrorHandler.shared.handle(error, context: "Failed to fetch photos")
        }
    }
    
    // Force reload data from Core Data - called when app becomes active
    func forceReloadFromDisk() {
        logPhotoOperation("forceReloadFromDisk", details: "Starting forced reload from Core Data")
        
        // Reset the context to ensure fresh data
        viewContext.reset()
        
        // Wait a moment for reset to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.loadPhotos()
            self?.loadTodaysPhoto()
        }
    }
    
    func loadTodaysPhoto() {
        let timer = PerformanceTimer("loadTodaysPhoto")
        logPhotoOperation("loadTodaysPhoto", details: "Starting daily photo load")
        
        // Get today's date string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        // Load all available photos
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)] // Consistent ordering
        
        do {
            let photos = try viewContext.fetch(request)
            
            if photos.isEmpty {
                let error = AppError.photoLoadFailed(context: "No photos available in gallery")
                logPhotoError("loadTodaysPhoto", error: error)
                ErrorHandler.shared.handle(error)
                timer.end()
                return
            }
            
            // Check if we already have a photo selected for today
            if todaysPhotoDate == todayString && !todaysPhotoId.isEmpty {
                // Try to find the previously selected photo for today
                if let savedPhoto = photos.first(where: { $0.id?.uuidString == todaysPhotoId }) {
                    currentPhoto = savedPhoto
                    logPhotoOperation("loadTodaysPhoto", details: "Loaded previously selected photo for today: \(todaysPhotoId)")
                    timer.end()
                    return
                }
            }
            
            // Select a new photo for today using consistent daily selection
            let today = Calendar.current.startOfDay(for: Date())
            let daysSinceEpoch = Int(today.timeIntervalSince1970 / 86400) // Days since epoch
            let photoIndex = daysSinceEpoch % photos.count
            
            currentPhoto = photos[photoIndex]
            
            // Store this selection for today
            todaysPhotoId = currentPhoto?.id?.uuidString ?? ""
            todaysPhotoDate = todayString
            
            logPhotoOperation("loadTodaysPhoto", details: "Selected new daily photo (index \(photoIndex)) from \(photos.count) available photos, saved as today's photo")
            
            timer.end()
        } catch {
            logPhotoError("loadTodaysPhoto", error: error)
            ErrorHandler.shared.handle(error, context: "Failed to fetch photos from gallery")
            timer.end()
        }
    }
    
    func addPhoto(image: UIImage, dayNumber: Int32) -> Bool {
        logPhotoOperation("addPhoto", details: "Adding photo for day \(dayNumber)")
        
        // Validate image
        guard validateImage(image) else {
            let error = AppError.corruptedPhoto(context: "Invalid image for day \(dayNumber)")
            ErrorHandler.shared.handle(error)
            return false
        }
        
        // Optimize image before saving
        guard let optimizedImage = optimizeImage(image) else {
            let error = AppError.photoSaveFailed(context: "Failed to optimize image for day \(dayNumber)")
            ErrorHandler.shared.handle(error)
            return false
        }
        
        let photo = Photo(context: viewContext)
        photo.id = UUID()
        photo.dayNumber = dayNumber
        photo.assignedDate = Date()
        photo.isViewed = false
        photo.isFavorite = false
        photo.dateAdded = Date()
        
        let imageName = "\(photo.id?.uuidString ?? UUID().uuidString).jpg"
        photo.imagePath = imageName
        
        // Save optimized image
        if saveImageToDocuments(image: optimizedImage, filename: imageName) {
            // Save immediately
            do {
                try viewContext.save()
                logPhotoOperation("addPhoto", details: "Photo saved successfully for day \(dayNumber)")
            } catch {
                logPhotoError("addPhoto", error: error)
                viewContext.delete(photo)
                return false
            }
            
            DispatchQueue.main.async {
                self.loadPhotos()
                self.loadTodaysPhoto()
                NotificationCenter.default.post(name: .photosUpdated, object: nil)
            }
            return true
        } else {
            // Remove photo entity if image save failed
            viewContext.delete(photo)
            return false
        }
    }
    
    func addPhotos(_ images: [UIImage], progressCallback: @escaping (Double, String) -> Void) -> Bool {
        let timer = PerformanceTimer("addPhotos_bulk")
        logPhotoOperation("addPhotos", details: "Starting bulk import of \(images.count) photos")
        
        guard !images.isEmpty else { return false }
        
        var successCount = 0
        
        for (index, image) in images.enumerated() {
            let dayNumber = Int32(index + 1) // Simple sequential assignment
            
            let progressPercent = Double(index) / Double(images.count)
            let progressMessage = "Processing photo \(index + 1) of \(images.count)..."
            progressCallback(progressPercent, progressMessage)
            
            if addPhoto(image: image, dayNumber: dayNumber) {
                successCount += 1
            }
        }
        
        timer.end()
        
        // Force save the context after bulk import
        saveContext()
        
        DispatchQueue.main.async {
            self.loadPhotos() // Refresh the photos array
            self.loadTodaysPhoto() // Refresh today's photo selection
            self.logPhotoOperation("addPhotos", details: "Completed bulk import: \(successCount)/\(images.count) photos successful")
            
            // Notify all views that photos have been updated
            self.logPhotoOperation("addPhotos", details: "Posting photosUpdated notification")
            NotificationCenter.default.post(name: .photosUpdated, object: nil)
        }
        
        let finalMessage = "Import complete: \(successCount) photos"
        progressCallback(1.0, finalMessage)
        
        return successCount > 0
    }
    
    func markPhotoAsViewed(_ photo: Photo) {
        photo.isViewed = true
        saveContext()
    }
    
    func toggleFavorite(_ photo: Photo) {
        photo.isFavorite.toggle()
        saveContext()
    }
    
    func updatePersonalNote(_ photo: Photo, note: String) {
        photo.personalNote = note
        saveContext()
    }
    
    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                logPhotoOperation("saveContext", details: "Context saved successfully with changes")
                
                // Force Core Data to write to disk
                if let coordinator = viewContext.persistentStoreCoordinator {
                    for store in coordinator.persistentStores {
                        do {
                            try coordinator.setMetadata(["lastSave": Date()], for: store)
                        } catch {
                            logPhotoError("saveContext", error: error)
                        }
                    }
                }
            } catch {
                logPhotoError("saveContext", error: error)
                ErrorHandler.shared.handle(error, context: "Core Data save failed")
            }
        } else {
            logPhotoOperation("saveContext", details: "No changes to save")
        }
    }
    
    private func saveImageToDocuments(image: UIImage, filename: String) -> Bool {
        logPhotoOperation("saveImageToDocuments", details: "Saving image: \(filename)")
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { 
            let error = AppError.photoSaveFailed(context: "Failed to compress image")
            logPhotoError("saveImageToDocuments", error: error)
            ErrorHandler.shared.handle(error)
            return false
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            // Ensure the documents directory exists
            try FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
            
            // Write the image data
            try data.write(to: fileURL)
            
            // Verify the file was actually written and is readable
            guard FileManager.default.fileExists(atPath: fileURL.path),
                  let _ = UIImage(contentsOfFile: fileURL.path) else {
                let error = AppError.photoSaveFailed(context: "Image file verification failed after save")
                logPhotoError("saveImageToDocuments", error: error)
                ErrorHandler.shared.handle(error)
                return false
            }
            
            // Add file attributes to prevent iCloud backup (for better local performance)
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = false // Allow backup for user data
            try fileURL.setResourceValues(resourceValues)
            
            logPhotoOperation("saveImageToDocuments", details: "Successfully saved and verified image: \(filename), size: \(data.count) bytes")
            return true
        } catch {
            logPhotoError("saveImageToDocuments", error: error)
            ErrorHandler.shared.handle(error, context: "Failed to save image to documents")
            return false
        }
    }
    
    // MARK: - Image Processing
    
    private func validateImage(_ image: UIImage) -> Bool {
        guard image.size.width > 0 && image.size.height > 0 else {
            return false
        }
        
        // Check minimum resolution (at least 100x100)
        guard image.size.width >= 100 && image.size.height >= 100 else {
            return false
        }
        
        // Check maximum resolution to prevent memory issues
        let maxDimension: CGFloat = 4096
        guard image.size.width <= maxDimension && image.size.height <= maxDimension else {
            return false
        }
        
        return true
    }
    
    private func optimizeImage(_ image: UIImage) -> UIImage? {
        let maxDimension: CGFloat = 2048
        let compressionQuality: CGFloat = 0.85
        
        // Calculate new size if needed
        let currentSize = image.size
        var newSize = currentSize
        
        if currentSize.width > maxDimension || currentSize.height > maxDimension {
            let aspectRatio = currentSize.width / currentSize.height
            
            if currentSize.width > currentSize.height {
                newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
            } else {
                newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
            }
        }
        
        // Resize if necessary
        if newSize != currentSize {
            guard let resizedImage = resizeImage(image, to: newSize) else {
                return nil
            }
            return resizedImage
        }
        
        return image
    }
    
    private func resizeImage(_ image: UIImage, to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func getImageFileSize(for photo: Photo) -> Int64 {
        guard let imagePath = photo.imagePath else { return 0 }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(imagePath)
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
    
    func getTotalStorageUsed() -> Int64 {
        var totalSize: Int64 = 0
        
        for photo in allPhotos {
            totalSize += getImageFileSize(for: photo)
        }
        
        return totalSize
    }
    
    func loadImageFromDocuments(filename: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            logPhotoError("loadImageFromDocuments", error: AppError.photoLoadFailed(context: "Image file not found: \(filename)"))
            
            // Try to recover by checking if the file exists with a different extension
            let baseFilename = URL(fileURLWithPath: filename).deletingPathExtension().lastPathComponent
            let possibleExtensions = ["jpg", "jpeg", "png", "JPG", "JPEG", "PNG"]
            
            for ext in possibleExtensions {
                let alternativeURL = documentsDirectory.appendingPathComponent("\(baseFilename).\(ext)")
                if FileManager.default.fileExists(atPath: alternativeURL.path) {
                    logPhotoOperation("loadImageFromDocuments", details: "Found alternative file: \(alternativeURL.lastPathComponent)")
                    if let image = UIImage(contentsOfFile: alternativeURL.path) {
                        return image
                    }
                }
            }
            
            return nil
        }
        
        guard let image = UIImage(contentsOfFile: fileURL.path) else {
            logPhotoError("loadImageFromDocuments", error: AppError.corruptedPhoto(context: "Cannot load image from file: \(filename)"))
            return nil
        }
        
        return image
    }
    
    private func getStartDate() -> Date? {
        let request: NSFetchRequest<Settings> = Settings.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let settings = try viewContext.fetch(request).first
            return settings?.startDate
        } catch {
            print("Error fetching settings: \(error)")
            return nil
        }
    }
    
    // MARK: - Storage Integrity
    
    func verifyAndRepairPhotoStorage() {
        logPhotoOperation("verifyAndRepairPhotoStorage", details: "Starting photo storage verification")
        
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        do {
            let photos = try viewContext.fetch(request)
            var repairedCount = 0
            var removedCount = 0
            
            for photo in photos {
                guard let imagePath = photo.imagePath else {
                    // Photo has no image path - remove it
                    viewContext.delete(photo)
                    removedCount += 1
                    continue
                }
                
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent(imagePath)
                
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    // Image file is missing - remove the photo record
                    logPhotoOperation("verifyAndRepairPhotoStorage", details: "Removing photo record for missing file: \(imagePath)")
                    viewContext.delete(photo)
                    removedCount += 1
                } else if UIImage(contentsOfFile: fileURL.path) == nil {
                    // Image file is corrupted - remove the photo record
                    logPhotoOperation("verifyAndRepairPhotoStorage", details: "Removing photo record for corrupted file: \(imagePath)")
                    try? FileManager.default.removeItem(at: fileURL)
                    viewContext.delete(photo)
                    removedCount += 1
                } else {
                    repairedCount += 1
                }
            }
            
            if removedCount > 0 {
                saveContext()
                loadPhotos() // Reload the photos array
            }
            
            logPhotoOperation("verifyAndRepairPhotoStorage", details: "Verification complete: \(repairedCount) valid photos, \(removedCount) removed")
            
        } catch {
            logPhotoError("verifyAndRepairPhotoStorage", error: error)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func getAllPhotoFilesInDocuments() -> [String] {
        let documentsDirectory = getDocumentsDirectory()
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: documentsDirectory.path)
            return files.filter { file in
                let lowercased = file.lowercased()
                return lowercased.hasSuffix(".jpg") || lowercased.hasSuffix(".jpeg") || lowercased.hasSuffix(".png")
            }
        } catch {
            logPhotoError("getAllPhotoFilesInDocuments", error: error)
            return []
        }
    }
    
    func getStorageStatus() -> (totalPhotos: Int, filesInDocuments: Int, missingFiles: Int) {
        let totalPhotos = allPhotos.count
        let filesInDocuments = getAllPhotoFilesInDocuments().count
        
        var missingFiles = 0
        for photo in allPhotos {
            guard let imagePath = photo.imagePath else {
                missingFiles += 1
                continue
            }
            
            let documentsDirectory = getDocumentsDirectory()
            let fileURL = documentsDirectory.appendingPathComponent(imagePath)
            
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                missingFiles += 1
            }
        }
        
        return (totalPhotos: totalPhotos, filesInDocuments: filesInDocuments, missingFiles: missingFiles)
    }
    
    // MARK: - Logging
    
    private func logPhotoOperation(_ operation: String, details: String) {
        print("PhotoManager.\(operation): \(details)")
    }
    
    private func logPhotoError(_ operation: String, error: Error) {
        print("PhotoManager.\(operation) ERROR: \(error)")
    }
}