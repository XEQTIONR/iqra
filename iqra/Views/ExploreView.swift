//
//  ExploreView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI
import CachedAsyncImage

struct ExploreView: View {
    var items = [1,2] // This represents the number of horizontal scroll items
    let imageUrls = [
        "https://picsum.photos/600/400",
        "https://picsum.photos/600/401",
        "https://picsum.photos/600/402",
        "https://picsum.photos/600/403",
        "https://picsum.photos/600/404"
    ]
    
    let courses = [
        "https://picsum.photos/600/400",
        "https://picsum.photos/600/401",
        "https://picsum.photos/600/402",
        "https://picsum.photos/600/403",
        "https://picsum.photos/600/404"
    ].map { Course(title: "\($0)", image: $0, description: $0) }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                List {
                    VStack(spacing: 15) {
                        HStack {
                            Text("Read the Quran in Arabic")
                                .font(.headline)
                                .foregroundStyle(.gray)
                            Spacer()
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(courses, id: \.self.image) { course in
                                    NavigationLink(destination: CourseView(course: course)) {
                                        Slide(title: course.title, url: course.image, width: geometry.size.width)
                                    }
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .safeAreaPadding(.horizontal, 0)
                    }
                    .padding(.horizontal, -5)
                    .listRowSeparator(.hidden)
                
                    VStack(spacing: 15) {
                        HStack {
                            Text("Quran Memorization Courses")
                                .font(.headline)
                                .foregroundStyle(.gray)
                            Spacer()
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(courses, id: \.self.image) { course in
                                    NavigationLink(destination: CourseView(course: course)) {
                                        Slide(title: course.title, url: course.image, width: geometry.size.width)
                                    }
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .safeAreaPadding(.horizontal, 0)
                    }
                    .padding(.horizontal, -5)
                    .listRowSeparator(.hidden)
                
                    VStack(spacing: 15) {
                        VStack(spacing: 10) {
                            HStack {
                                Text("Arabic Speaking Courses")
                                    .font(.headline)
                                    .foregroundStyle(.gray)
                                Spacer()
                            }
                        }
                       
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(courses, id: \.self.image) { course in
                                    NavigationLink(destination: CourseView(course: course)) {
                                        Slide(title: course.title, url: course.image, width: geometry.size.width)
                                    }
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .safeAreaPadding(.horizontal, 0)
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
                .listRowSpacing(30)
            }
            .navigationDestination(for: Course.self) { course in
                CourseView(course: course)
            }
        }
    }
}

#Preview {
    ExploreView()
}
