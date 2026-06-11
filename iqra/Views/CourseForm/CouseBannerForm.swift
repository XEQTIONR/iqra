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
    
    @Binding var formData: CourseFormData
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
                        Button("Save") {
                            Task {
                                let serverURL = URL(string: "http://localhost:8000/api/uploads")!
                                
                                do {
                                    let (videoData, _, ok1) = try await RequestService.uploadFileUrl(videoUrl!, serverURL: serverURL, fieldName: "file")
                                    
                                    if !ok1 {
                                        print("Error")
                                        // @TODO: error handle here
                                        return
                                    }
                                    
                                    let (imageData, _, ok2) = try await RequestService.uploadImage(selectedImage!, serverURL: serverURL, fieldName: "file")
                                    
                                    if !ok2 {
                                        print("Error")
                                        // @TODO: error handle here
                                        return
                                    }
        
                                    let video = try RequestService.apiUnwrapData(type: File.self, from: videoData)
                                    let image = try RequestService.apiUnwrapData(type: File.self, from: imageData)
                                    
                                    formData.video = video.path
                                    formData.image = image.path
                                    
                                    let (data,_,ok) = try await RequestService.request(
                                        COURSES_ENDPOINT,
                                        method: "POST",
                                        headers: RequestService.authJsonHeaders,
                                        body: JSONEncoder().encode(formData)
                                    )
                                    
                                    print(data)
                                    
                                    if !ok {
                                        print ("Error")
                                        //@TODO: error handle
                                        return
                                    }
                                    
                                    let course = try RequestService.apiUnwrapData(type: Course.self, from: data)
                                    onComplete?(course)
                                   
                                } catch {
                                    print(error)
                                    // @TODO: Error handle here
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
            CourseFormData(
                title: "SOme text",
                description: "Other text",
                image: "Test",
                video: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                difficulty: .advanced,
                category: .reading,
                length_type: .fixed,
                age_groups: [.kids, .teens]
            ),
        ),
        videoUrl: .constant(
            URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
        ),
        onComplete: nil
    )
}
