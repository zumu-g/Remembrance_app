import SwiftUI
import UIKit
import AVFoundation
import Photos

class PhotoCaptureManager: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var showingImagePicker = false
    @Published var showingCamera = false
    @Published var showingPermissionAlert = false
    
    enum ImageSource {
        case camera
        case photoLibrary
    }
    
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized || status == .limited)
            }
        }
    }
    
    func checkPermissions(for source: ImageSource, completion: @escaping (Bool) -> Void) {
        switch source {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == .authorized {
                completion(true)
            } else if status == .notDetermined {
                requestCameraPermission(completion: completion)
            } else {
                completion(false)
            }
        case .photoLibrary:
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .authorized || status == .limited {
                completion(true)
            } else if status == .notDetermined {
                requestPhotoLibraryPermission(completion: completion)
            } else {
                completion(false)
            }
        }
    }
    
    func presentImagePicker(source: ImageSource) {
        checkPermissions(for: source) { [weak self] granted in
            if granted {
                switch source {
                case .camera:
                    self?.showingCamera = true
                case .photoLibrary:
                    self?.showingImagePicker = true
                }
            } else {
                self?.showingPermissionAlert = true
            }
        }
    }
    
    func saveImageToDocuments(_ image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func loadImageFromDocuments(_ fileName: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}