//
//  CourseImage.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-09.
//

import SwiftUI



enum GenericError: Error {
    case generic
}

struct CourseBannerForm: View {
    
    @Binding var formData: Course
    @Binding var videoUrl: URL?
    var onComplete: ((_ course: Course) -> Void)? = nil
    
    @State private var showPicker = false
    @State private var selectedImage: UIImage?

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
                    
                    if selectedImage == nil {
                        Button("Select Media") {
                            showPicker = true
                        }
                    } else {
                        Button("Clear Image", role: .destructive) {
                            selectedImage = nil
                        }
                        
                        NavigationLink {
                            CourseFormatForm(
                                formData: $formData,
                                videoUrl: $videoUrl,
                                image: $selectedImage,
                                onComplete: onComplete
                            )
                        } label: {
                            HStack {
                                Image(systemName: "chevron.right")
                                    .padding(.leading)
                                    .opacity(0)
                                Spacer()
                                Text("Continue")
                                    .padding(.all, 10)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .padding(.trailing)
                            }
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .cornerRadius(10)
                            .foregroundStyle(.white)
                        }
                        
                        
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            
        }
                .navigationTitle("Course Banner")
                .sheet(isPresented: $showPicker) {
                    MediaPicker(photo: $selectedImage)
                }
        
        }
    }
}

#Preview {
    CourseBannerForm(
        formData: .constant(
            Course(
                title: "Some text",
                description: "Other text",
                image: "Test",
                video: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                difficulty: .advanced,
                category: .reading,
                lengthType: .fixed,
                ageGroups: [.kids, .teens]
            ),
        ),
        videoUrl: .constant(
            URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
        ),
        onComplete: nil
    )
}
