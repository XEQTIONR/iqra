//
//  ExploreView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI
import CachedAsyncImage

struct ExploreView: View {
    @Environment(User.self) private var appUser
    
    @State private var router = Router()
    @State var courses: [Course] = []
    @State var showLoginSheet: Bool = false
    @State var showInstructorSheet: Bool = false
    @State var showCourseSheet: Bool = false
    @State private var navigateToInstructorForm: Bool = false
    
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
        @Bindable var router = router
        return GeometryReader { geometry in
            NavigationStack(path: $router.path) {
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
                                    NavigationLink(value: Route.course(course)) {
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
                                    NavigationLink(value: Route.course(course)) {
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
                                    NavigationLink(value: Route.course(course)) {
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
                        Button("Add your own course") {
                            if appUser.id == nil {
                                showLoginSheet = true
                                navigateToInstructorForm = true
                            } else if appUser.isInstructor == false {
                                showInstructorSheet = true
                            } else {
                                showCourseSheet = true
                            }
                            
                        }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.all, 10)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .listRowSeparator(.hidden)
                        
//                    }
                    
                    
                }
                .listStyle(PlainListStyle())
                .listRowSpacing(30)
                .navigationDestination(for: Route.self) { route in
                    route.destination
                        .environment(router)
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            // Action here
                        }) {
                            Image(systemName: "bell.badge")
                                .renderingMode(.original)
                        }
                    }
                }
            }
            .environment(router)
            .sheet(isPresented: $showInstructorSheet) {
                InstructorArabicFormView(completion: {
                    showInstructorSheet = false
                    showCourseSheet = true
                })
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginView(completion: {
                    showLoginSheet = false
                    
                    if navigateToInstructorForm {
                        
                        if appUser.isInstructor == true {
                            showCourseSheet = true
                        } else {
                            showInstructorSheet = true
                        }
                        
                        navigateToInstructorForm = false
                        
                    }
                })
            }
            .sheet(isPresented: $showCourseSheet) {
                CourseForm()
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
