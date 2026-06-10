//
//  CourseImage.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-09.
//

import SwiftUI

struct CourseBannerForm: View {
    
    @Binding var formData: CourseFormData
    @Binding var videoUrl: URL?
    
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
                        Button("Save") {
                            Task {
                                var (data, _, ok) = try await RequestService.request(
                                    "http://localhost:8000/api/courses",
                                    method: "POST",
                                    headers: RequestService.authJsonHeaders,
                                    body: JSONEncoder().encode(formData)
                                )
                                
                                if ok {
                                    print("course created")
                                    
                                    do {
                                        let course = try RequestService.apiUnwrapData(type: Course.self, from: data)
                                    
                                    
                                        (data, _, ok) = try await RequestService.uploadMultipartFile(
                                            fileURL: videoUrl!,
                                            fieldName: "video",
                                            to: URL(string: "http://localhost:8000/api/courses/\(course.id)/video")!
                                        )
                                        
                                        if ok {
                                            print("video uploaded")
                                        } else {
                                            print("2nd failed")
                                        }
                                        print("data after upload")
                                        print(String(data: data, encoding: .utf8))
                                    } catch {
                                        print(error)
                                    }
                                } else {
                                    print(String(data: data, encoding: .utf8))
                                    print("1st failed")
                                }
                            }
                        }
                        
                        Button("Clear Image", role: .destructive) {
                            selectedImage = nil
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
            MediaPicker(photo: $selectedImage)
        }
        
    }
}

#Preview {
    CourseBannerForm(
        formData: .constant(
            CourseFormData(
                title: "Test",
                description: "The description of this course",
                difficulty: .advanced,
                category: .reading,
                length_type: .fixed,
                age_groups: [.kids, .teens]
            ),
        ),
        videoUrl: .constant(
            URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
        )
    )
}
