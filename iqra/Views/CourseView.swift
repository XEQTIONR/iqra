//
//  CourseView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-24.
//

import SwiftUI

struct CourseView: View {
    
    
    let course: Course
    
    var body: some View {
        VStack {
            
            AsyncImage(url: URL(string: course.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray
            }
            
            HStack {
                Text(course.title)
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            
            Button("Enroll", action: {
                Task {
                    let token = UserDefaults.standard.value(forKey: "api_token") as! String
                    let (data, response, ok) = try await RequestService.request(
                        "http://localhost:8000/api/jwt",
                        headers: [
                            "Content-Type": "application/json",
                            "Accept": "application/json",
                            "Authorization": "Bearer \(token)"
                        ],
                    )
                    
                    if ok {
                        UserDefaults.standard.set(String(data: data, encoding: .utf8), forKey: "jwt")
                    } else {
                        /// do error handling here
                    }
                }
            })
            
            Spacer()
        }
        
    }
}

#Preview {
    CourseView(course: Course(title: "My Course", image: "https://picsum.photos/600/400", description: "A dummy description"))
}
