//
//  CourseImage.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-09.
//

import SwiftUI

struct CourseBannerForm: View {
    @State private var showPicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedVideoURL: URL?

    var body: some View {
        
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding(.top, 15)
        //                    .frame(maxHeight: .infinity)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                            .frame(width: 50)
                    }
                    
                    if selectedImage == nil && selectedVideoURL == nil {
                        Button("Select Media") {
                            showPicker = true
                        }
                    } else {
                        Button("Save") {
                            print("Save t")
                        }
                        
                        Button("Clear Image", role: .destructive) {
                            selectedImage = nil
                            selectedVideoURL = nil
                        }
                        
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
//                .background(Color.gray.opacity(0.2))
                
                
            }
            .navigationTitle("Course Banner")
            
        }
        .sheet(isPresented: $showPicker) {
            MediaPicker(selectedImage: $selectedImage, selectedVideoURL: $selectedVideoURL)
        }
        
    }
}

#Preview {
    CourseBannerForm()
}
