//
//  PhotoManagerTests.swift
//  Remembrance
//
//  Created by Stuart Grant on 8/7/2025.
//

import Testing
import CoreData
import UIKit
@testable import Remembrance

struct PhotoManagerTests {
    
    // MARK: - Test Image Optimization
    
    @Test func testImageOptimization() async throws {
        let photoManager = PhotoManager()
        
        // Create a large test image
        let largeImage = createTestImage(width: 5000, height: 5000)
        #expect(largeImage.size.width == 5000)
        #expect(largeImage.size.height == 5000)
        
        // Test image validation
        let isValid = photoManager.validateImage(largeImage)
        #expect(isValid == false) // Should be invalid due to size
        
        // Create a valid test image
        let validImage = createTestImage(width: 1000, height: 1000)
        let isValidImage = photoManager.validateImage(validImage)
        #expect(isValidImage == true)
    }
    
    @Test func testImageResizing() async throws {
        let photoManager = PhotoManager()
        
        // Create a large but valid image
        let originalImage = createTestImage(width: 3000, height: 3000)
        
        // Test optimization
        let optimizedImage = photoManager.optimizeImage(originalImage)
        #expect(optimizedImage != nil)
        #expect(optimizedImage!.size.width <= 2048)
        #expect(optimizedImage!.size.height <= 2048)
    }
    
    @Test func testImageCompressionQuality() async throws {
        let testImage = createTestImage(width: 1000, height: 1000)
        
        // Test JPEG compression
        let jpegData = testImage.jpegData(compressionQuality: 0.8)
        #expect(jpegData != nil)
        #expect(jpegData!.count > 0)
        
        // Ensure we can recreate the image
        let recreatedImage = UIImage(data: jpegData!)
        #expect(recreatedImage != nil)
        #expect(recreatedImage!.size.width == testImage.size.width)
        #expect(recreatedImage!.size.height == testImage.size.height)
    }
    
    // MARK: - Test Bulk Photo Import
    
    @Test func testBulkPhotoImport() async throws {
        let controller = PersistenceController(inMemory: true)
        let photoManager = PhotoManager()
        
        // Create test images
        let testImages = (1...10).map { _ in
            createTestImage(width: 500, height: 500)
        }
        
        var progressUpdates: [(Double, String)] = []
        
        // Test bulk import
        let success = photoManager.addPhotos(testImages) { progress, message in
            progressUpdates.append((progress, message))
        }
        
        #expect(success == true)
        #expect(progressUpdates.count > 0)
        #expect(progressUpdates.last?.0 == 1.0) // Final progress should be 100%
    }
    
    @Test func testPhotoAssignmentTo365Days() async throws {
        let photoManager = PhotoManager()
        
        // Test with fewer than 365 photos
        let testImages = (1...50).map { _ in
            createTestImage(width: 300, height: 300)
        }
        
        let success = photoManager.addPhotos(testImages) { _, _ in }
        #expect(success == true)
        
        // Verify all 365 days are filled
        #expect(photoManager.allPhotos.count == 365)
        
        // Verify photos cycle correctly
        let day1Photo = photoManager.allPhotos.first { $0.dayNumber == 1 }
        let day51Photo = photoManager.allPhotos.first { $0.dayNumber == 51 }
        
        #expect(day1Photo != nil)
        #expect(day51Photo != nil)
        #expect(day1Photo?.imagePath != day51Photo?.imagePath) // Should be different images
    }
    
    // MARK: - Test Photo Storage
    
    @Test func testPhotoStorageAndRetrieval() async throws {
        let photoManager = PhotoManager()
        let testImage = createTestImage(width: 400, height: 400)
        
        // Test adding a single photo
        let success = photoManager.addPhoto(image: testImage, dayNumber: 100)
        #expect(success == true)
        
        // Test retrieval
        let photo = photoManager.allPhotos.first { $0.dayNumber == 100 }
        #expect(photo != nil)
        #expect(photo?.imagePath != nil)
        
        // Test loading image from documents
        if let imagePath = photo?.imagePath {
            let loadedImage = photoManager.loadImageFromDocuments(filename: imagePath)
            #expect(loadedImage != nil)
            #expect(loadedImage!.size.width > 0)
            #expect(loadedImage!.size.height > 0)
        }
    }
    
    // MARK: - Test File Size Calculations
    
    @Test func testStorageCalculations() async throws {
        let photoManager = PhotoManager()
        
        // Add a test photo
        let testImage = createTestImage(width: 500, height: 500)
        let success = photoManager.addPhoto(image: testImage, dayNumber: 1)
        #expect(success == true)
        
        if let photo = photoManager.allPhotos.first {
            let fileSize = photoManager.getImageFileSize(for: photo)
            #expect(fileSize > 0) // Should have a positive file size
        }
        
        let totalStorage = photoManager.getTotalStorageUsed()
        #expect(totalStorage > 0) // Should have positive total storage
    }
    
    // MARK: - Test Error Handling
    
    @Test func testInvalidImageHandling() async throws {
        let photoManager = PhotoManager()
        
        // Create an invalid image (too small)
        let tinyImage = createTestImage(width: 50, height: 50)
        let success = photoManager.addPhoto(image: tinyImage, dayNumber: 1)
        #expect(success == false) // Should fail validation
        
        // Verify no photo was added
        let photos = photoManager.allPhotos.filter { $0.dayNumber == 1 }
        #expect(photos.isEmpty == true)
    }
    
    @Test func testEmptyImportHandling() async throws {
        let photoManager = PhotoManager()
        
        let success = photoManager.addPhotos([]) { _, _ in }
        #expect(success == false) // Should fail for empty array
    }
    
    // MARK: - Helper Functions
    
    private func createTestImage(width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        // Fill with a solid color
        UIColor.blue.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}