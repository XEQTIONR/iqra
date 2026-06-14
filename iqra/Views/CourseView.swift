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
            
            
            VStack(alignment: .leading) {
                Text(course.title)
                    .background(.blue.opacity(0.2))

                Text(course.description)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.red.opacity(0.2))
            
            
            
            Button("Enroll", action: {
                Task {
                    let token = UserDefaults.standard.value(forKey: "api_token") as! String
                    var headers = ["Authorization": "Bearer \(token)"]
                    headers.merge(RequestService.jsonHeaders) { (current, new) in new }
                    
                    let (data, _, ok) = try await RequestService.request(
                        "http://localhost:8000/api/jwt",
                        headers: headers,
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
    CourseView(course: Course(
        id: 1,
        title: "My Course",
        description: "A dummy description", image: "https://picsum.photos/600/400",
        video: "",
        difficulty: .beginner,
        category: .reading,
        lengthType: .fixed,
        ageGroups: [.kids, .teens],
        isPublished: true
    ))
}
