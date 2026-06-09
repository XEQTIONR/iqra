//
//  MediaPickerViewController.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-09.
//

import SwiftUI
import PhotosUI

// For UIKit
class MediaPickerViewController: UIViewController, PHPickerViewControllerDelegate {
    
    func presentPicker() {
        var config = PHPickerConfiguration()
        config.filter = .any(of: [.images, .videos]) // Both images and videos
        config.selectionLimit = 1 // Set to 0 for unlimited, or any number
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        // Handle image
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        // Use the image
                        print("Image selected: \(image)")
                    }
                }
            }
        }
        
        // Handle video
        if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                guard let url = url else { return }
                
                // Copy to permanent location
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
                
                try? FileManager.default.copyItem(at: url, to: destinationURL)
                
                DispatchQueue.main.async {
                    print("Video saved to: \(destinationURL)")
                }
            }
        }
    }
}

// SwiftUI Wrapper
struct MediaPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var selectedVideoURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .any(of: [.images, .videos])
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MediaPicker
        
        init(_ parent: MediaPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let result = results.first else { return }
            
            // Handle image
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
            
            // Handle video
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    guard let url = url else { return }
                    
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
                    
                    try? FileManager.default.copyItem(at: url, to: destinationURL)
                    
                    DispatchQueue.main.async {
                        self.parent.selectedVideoURL = destinationURL
                    }
                }
            }
        }
    }
}
