//
//  ExploreView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI
import CachedAsyncImage

struct ExploreView: View {
    private enum Destination: Hashable {
        case instructorForm
    }
    
    @Environment(User.self) private var appUser
    
    @State var courses: [Course] = []
    @State var showLoginSheet: Bool = false
    @State private var navigateToInstructorForm: Bool = false
    
    @State private var path = NavigationPath()
    
    private func loadFeed() async {
        do {
            let (data, _, _) = try await RequestService.request(
                "http://localhost:8000/api/feed",
                headers: RequestService.jsonHeaders
            )
            print("data")
            print(String(data: data, encoding: .utf8) ?? "No data")

            courses = try JSONDecoder().decode([Course].self, from: data)
        } catch {
            // do nothing
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $path) {
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
                    
                    if (appUser.id == nil) {
                        Button("Add your own course") {
                            showLoginSheet = true
                        }
                    } else {
                        NavigationLink(destination: InstructorFormView()) {
                            Button("Add your own course") {
                                
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.all, 10)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .listRowSeparator(.hidden)
                        }
                    }
                    
                    
                }
                .listStyle(PlainListStyle())
                .listRowSpacing(30)
                .navigationDestination(for: Destination.self) { destination in
                    switch destination {
                    case .instructorForm:
                        InstructorFormView()
                    }
                }
                .navigationDestination(for: Course.self) { course in
                    CourseView(course: course)
                }
            }
            .sheet(isPresented: $showLoginSheet, onDismiss: {
                if navigateToInstructorForm {
                    navigateToInstructorForm = false
                    path.append(Destination.instructorForm)
                }
            }) {
                LoginView(completion: {
                    navigateToInstructorForm = true
                    showLoginSheet = false
                })
            }
            .task {
                await loadFeed()
            }
        }
    }
}

#Preview {
    ExploreView()
        .environment(User())
}
