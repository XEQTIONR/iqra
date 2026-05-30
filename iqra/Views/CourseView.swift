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
            
            Spacer()
        }
        
    }
}

#Preview {
    CourseView(course: Course(title: "My Course", image: "https://picsum.photos/600/400", description: "A dummy description"))
}
