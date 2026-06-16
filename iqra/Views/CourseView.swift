//
//  CourseView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-24.
//

import SwiftUI

struct CourseView: View {
    
    
    let course: Course
    @State private var isExpanded: Bool = false
    @State private var i = 0
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: course.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray
            }

            VStack(spacing: 50) {
                VStack(alignment: .leading, spacing: 20) {
                    Text(course.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(course.description)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        HStack {
                            Text("Difficulty:")
                                .fontWeight(.semibold)
                            Text(course.difficulty.rawValue.capitalized)
                            Spacer()
                        }
                        .containerRelativeFrame(.horizontal) { length, axis in
                            return length * 0.45
                        }
                        Spacer()
                        HStack {
                            Text("Category:")
                                .fontWeight(.semibold)
                            Text(course.category.rawValue.capitalized)
                            Spacer()
                        }
                        .containerRelativeFrame(.horizontal) { length, axis in
                            return length * 0.45
                        }
                        
                    }
                    .font(.caption)
                    HStack {
                        
                        
                        
                        HStack {
                            Text("Age Groups:")
                                .fontWeight(.semibold)
                            Text(course.ageGroups.map({ $0.rawValue.capitalized }).joined(separator: ", "))
                            Spacer()
                        }
                        .containerRelativeFrame(.horizontal) { length, axis in
                            return length * 0.45
                        }
                        HStack {
                            Text("Length Type:")
                                .fontWeight(.semibold)
                            Text(course.lengthType.rawValue.capitalized)
                            Spacer()
                            
                        }
                    }
                    .font(.caption)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                DisclosureGroup("Enroll in this course", isExpanded: $isExpanded) {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(0..<course.formats.count, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(course.formats[index].title)
                                        .foregroundStyle(i == index ? .blue : .secondary)
                                        .font(.title2.bold())
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Circle()
                                        .fill(i == index ? .blue : .secondary)
                                        .frame(width: 20, height: 20)
                                        .overlay {
                                            if index == i {
                                                Circle()
                                                    .fill(.white)
                                                    .frame(width: 12, height: 12)
                                            }
                                        }
                                }
                                
                                Text("$ \(course.formats[index].price) per \(course.formats[index].unit)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text(course.formats[index].description)
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .onTapGesture {
                                i = index
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(i == index ? .blue : .secondary, lineWidth: 1)
                            )
                        }
                        
                        NavigationLink {
                            CourseScheduleView(
                                format: course.formats[i],
                                course: course
                            )
                        } label : {
                            Text("Continue")
                                .frame(maxWidth: .infinity)
                                .padding(.all, 10)
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 10))
                        }
//                        Button("Continue") {
//                            
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.all, 10)
//                        .background(.blue)
//                        .foregroundStyle(.white)
//                        .clipShape(.rect(cornerRadius: 10))
                            
                    }
                    .padding(.top)
                    
                }
            }
            .padding()
            
            
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
        isPublished: true,
        formats: [
            CourseFormat(
                title: "Format title",
                description: "A 1-week trial that can to give this a go",
                unit: .lesson,
                lessonLength: 60,
                lessonsPerWeek: 2,
                price: 50,
                billingCycles: 10
                
            ),
            CourseFormat(
                title: "Format title 2",
                description: "A 1-week trial that can to give this a go",
                unit: .lesson,
                lessonLength: 60,
                lessonsPerWeek: 2,
                price: 50,
                billingCycles: 10
                
            )
        ]
    ))
}
