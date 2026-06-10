//
//  PickerView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-09.
//

import SwiftUI

struct PickerView: View {
    
    @State private var showPicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedVideoURL: URL?

    var body: some View {
        ZStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 15)
//                    .frame(maxHeight: .infinity)
            }
            
            else if let videoURL = selectedVideoURL {
                Text("Video selected: \(videoURL.lastPathComponent)")
            }
            
            Button("Select Media") {
                showPicker = true
            }
        }
        .sheet(isPresented: $showPicker) {
            MediaPicker(photo: $selectedImage, video: $selectedVideoURL)
        }
    }
}

#Preview {
    PickerView()
}
