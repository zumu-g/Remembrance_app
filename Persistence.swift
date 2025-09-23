import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let samplePhoto = Photo(context: viewContext)
        samplePhoto.id = UUID()
        samplePhoto.dayNumber = 1
        samplePhoto.assignedDate = Date()
        samplePhoto.imagePath = "sample_image"
        samplePhoto.isViewed = false
        samplePhoto.isFavorite = false
        samplePhoto.dateAdded = Date()
        
        do {
            try viewContext.save()
        } catch {
            ErrorHandler.shared.handle(error, context: "Preview data creation")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DataModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Ensure we're using the default persistent store location
            let storeURL = NSPersistentContainer.defaultDirectoryURL()
                .appendingPathComponent("DataModel.sqlite")
            
            if let description = container.persistentStoreDescriptions.first {
                description.url = storeURL
                description.shouldMigrateStoreAutomatically = true
                description.shouldInferMappingModelAutomatically = true
                
                print("PersistenceController: Core Data store URL: \(storeURL)")
            }
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                ErrorHandler.shared.handle(error, context: "Core Data store initialization")
                fatalError("Core Data failed to load: \(error)")
            } else {
                print("PersistenceController: Core Data loaded successfully from: \(storeDescription.url?.path ?? "unknown")")
            }
        }
        
        // Configure view context for better persistence
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Add notification observer to save context when app goes to background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveContext),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @objc private func saveContext() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                print("PersistenceController: Context saved successfully")
            } catch {
                ErrorHandler.shared.handle(error, context: "Failed to save context on app background")
            }
        }
    }
}