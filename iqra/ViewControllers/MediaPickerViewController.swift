//
//  MediaPickerViewController.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-09.
//

import SwiftUI
import PhotosUI

// Defines which kinds of media the picker is allowed to select.
enum MediaPickerType {
    case photo
    case video
    case both

    var filter: PHPickerFilter {
        switch self {
        case .photo:
            return .images
        case .video:
            return .videos
        case .both:
            return .any(of: [.images, .videos])
        }
    }
}

// For UIKit
class MediaPickerViewController: UIViewController, PHPickerViewControllerDelegate {

    var mediaType: MediaPickerType = .both

    func presentPicker() {
        var config = PHPickerConfiguration()
        config.filter = mediaType.filter
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
    private let selectedImage: Binding<UIImage?>?
    private let selectedVideoURL: Binding<URL?>?
    let mediaType: MediaPickerType
    @Environment(\.dismiss) private var dismiss

    // Photo only
    init(photo: Binding<UIImage?>) {
        self.selectedImage = photo
        self.selectedVideoURL = nil
        self.mediaType = .photo
    }

    // Video only
    init(video: Binding<URL?>) {
        self.selectedImage = nil
        self.selectedVideoURL = video
        self.mediaType = .video
    }

    // Both photo and video
    init(photo: Binding<UIImage?>, video: Binding<URL?>) {
        self.selectedImage = photo
        self.selectedVideoURL = video
        self.mediaType = .both
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = mediaType.filter
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
            if let imageBinding = parent.selectedImage,
               result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        imageBinding.wrappedValue = image as? UIImage
                    }
                }
            }
            
            // Handle video
            if let videoBinding = parent.selectedVideoURL,
               result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    guard let url = url else { return }
                    
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
                    
                    try? FileManager.default.copyItem(at: url, to: destinationURL)
                    
                    DispatchQueue.main.async {
                        videoBinding.wrappedValue = destinationURL
                    }
                }
            }
        }
    }
}
