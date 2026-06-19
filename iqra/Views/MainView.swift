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

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            TabView(selection: $selectedTab) {
                Tab("Explore", systemImage: "magnifyingglass", value: 0) {
                    ExploreView()
                }
                Tab("Calendar", systemImage: "calendar", value: 1) {
                    CalendarView()
                }
                Tab("Lessons", systemImage: "graduationcap", value: 2) {
                    MyCoursesView()
                }
                Tab("Resources", systemImage: "book.pages", value: 3) {
                    IntroView(.constant(ContentSection.intro))
                }
                Tab("Settings", systemImage: "gearshape", value: 4) {
                    SettingsView($currentSection)
                }
            }
            .navigationDestination(for: Route.self) { route in
                route.destination
                    .environment(router)
            }
        }
        .environment(router)
    }
}

#Preview {
    MainView(currentSection: .constant(.main))
        .environment(User())
}
