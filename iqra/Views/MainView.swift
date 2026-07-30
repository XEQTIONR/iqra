//  MainView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI
import SwiftData


extension EnvironmentValues {
    @Entry var selectedTab: Binding<Int>?
}

struct MainView: View {
    
    @Binding var currentSection: ContentSection
    
    @State private var router = Router()
    @State private var selectedTab = 0
    @State private var exploreTabBarVisibility = Visibility.visible

    var body: some View {
        @Bindable var router = router
        TabView(selection: $selectedTab) {
            Tab("Explore", systemImage: "magnifyingglass", value: 0) {
                NavigationStack(path: $router.path) {
                    ExploreView()
                        .onAppear { exploreTabBarVisibility = .visible }
                        .navigationDestination(for: Route.self) { route in
                            route.destination
                                .environment(router)
                                .onAppear {
                                    if isCourseRoute(route) {
                                        exploreTabBarVisibility = .hidden
                                    }
                                }
                        }
                }
                .toolbar(exploreTabBarVisibility, for: .tabBar)
                .onChange(of: router.path.count) { _, count in
                    if count == 0 {
                        exploreTabBarVisibility = .visible
                    }
                }
            }
            Tab("Lessons", systemImage: "calendar", value: 1) {
                NavigationStack(path: $router.path) {
                    ScheduleView()
                }
            }
            Tab("My Courses", systemImage: "graduationcap", value: 2) {
                NavigationStack(path: $router.path) {
                    MyCoursesView()
                }
            }
            Tab("Resources", systemImage: "book.pages", value: 3) {
                NavigationStack(path: $router.path) {
                    IntroView(.constant(ContentSection.intro))
                }
            }
            Tab("Settings", systemImage: "gearshape", value: 4) {
                NavigationStack(path: $router.path) {
                    SettingsView($currentSection)
                }
            }
        }
        .environment(router)
    }

    private func isCourseRoute(_ route: Route) -> Bool {
        if case .course = route { return true }
        return false
    }
}

#Preview {
    MainView(currentSection: .constant(.main))
        .environment(User())
}
