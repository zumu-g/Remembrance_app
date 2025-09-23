//
//  PhotoViewModel.swift
//  Remembrance
//
//  Created by Stuart Grant on 8/7/2025.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
class PhotoViewModel: ObservableObject {
    @Published var currentPhoto: Photo?
    @Published var allPhotos: [Photo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentDayNumber: Int = 1
    @Published var totalDays: Int = 365
    
    private let photoManager: PhotoManager
    private let settingsManager: SettingsManager
    
    init(photoManager: PhotoManager = PhotoManager.shared, settingsManager: SettingsManager = SettingsManager()) {
        self.photoManager = photoManager
        self.settingsManager = settingsManager
        
        setupBindings()
        loadInitialData()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        photoManager.$currentPhoto
            .assign(to: &$currentPhoto)
        
        photoManager.$allPhotos
            .assign(to: &$allPhotos)
    }
    
    private func loadInitialData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                await loadTodaysPhoto()
                await calculateCurrentDay()
                isLoading = false
            } catch {
                errorMessage = "Failed to load today's photo: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    // MARK: - Photo Operations
    
    func loadTodaysPhoto() async {
        photoManager.loadTodaysPhoto()
        await calculateCurrentDay()
    }
    
    func refreshPhotos() async {
        isLoading = true
        photoManager.loadPhotos()
        await loadTodaysPhoto()
        isLoading = false
    }
    
    func markCurrentPhotoAsViewed() {
        guard let photo = currentPhoto else { return }
        photoManager.markPhotoAsViewed(photo)
    }
    
    func toggleCurrentPhotoFavorite() {
        guard let photo = currentPhoto else { return }
        photoManager.toggleFavorite(photo)
    }
    
    func updateCurrentPhotoNote(_ note: String) {
        guard let photo = currentPhoto else { return }
        photoManager.updatePersonalNote(photo, note: note)
    }
    
    func addPhotos(_ images: [UIImage]) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let success = photoManager.addPhotos(images) { progress, message in
            // Progress callback can be used later if needed
        }
        
        if success {
            await refreshPhotos()
        } else {
            errorMessage = "Failed to add some photos. Please try again."
        }
        
        isLoading = false
        return success
    }
    
    // MARK: - Helper Methods
    
    private func calculateCurrentDay() async {
        guard let startDate = settingsManager.settings?.startDate else {
            currentDayNumber = 1
            return
        }
        
        let calendar = Calendar.current
        let today = Date()
        let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0
        currentDayNumber = (daysSinceStart % 365) + 1
    }
    
    func getDayProgress() -> Double {
        return Double(currentDayNumber) / Double(totalDays)
    }
    
    func getProgressText() -> String {
        return "Day \(currentDayNumber) of \(totalDays)"
    }
    
    func hasPhotosForAllDays() -> Bool {
        return allPhotos.count >= 365
    }
    
    func getPhotosCount() -> Int {
        return allPhotos.count
    }
    
    func getRemainingPhotosCount() -> Int {
        return max(0, 365 - allPhotos.count)
    }
    
    // MARK: - Error Handling
    
    func clearError() {
        errorMessage = nil
    }
    
    func retryLastOperation() {
        Task {
            await loadTodaysPhoto()
        }
    }
}

// MARK: - Photo Status Helpers

extension PhotoViewModel {
    var hasCurrentPhoto: Bool {
        return currentPhoto != nil
    }
    
    var currentPhotoImage: UIImage? {
        guard let photo = currentPhoto,
              let imagePath = photo.imagePath else { return nil }
        
        return photoManager.loadImageFromDocuments(filename: imagePath)
    }
    
    var isCurrentPhotoViewed: Bool {
        return currentPhoto?.isViewed ?? false
    }
    
    var isCurrentPhotoFavorite: Bool {
        return currentPhoto?.isFavorite ?? false
    }
    
    var currentPhotoNote: String {
        return currentPhoto?.personalNote ?? ""
    }
    
    var currentPhotoDate: Date? {
        return currentPhoto?.assignedDate
    }
}