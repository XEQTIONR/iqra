//  MainView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI
import SwiftData


struct MainView: View {
    
    @Binding var currentSection: ContentSection
    
    @State var courses: [Course] = []
    @State var router = Router()

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            TabView {
                Tab("Explore", systemImage: "magnifyingglass") {
                    ExploreView()
                }
                Tab("Calendar", systemImage: "calendar") {
                    CalendarView()
                }
                Tab("Lessons", systemImage: "graduationcap") {
                    UserTypeView()
                }
                Tab("Resources", systemImage: "book.pages") {
                    IntroView(.constant(ContentSection.intro))
                }
                Tab("Settings", systemImage: "gearshape") {
                    SettingsView($currentSection)
                }
            }
        }
        .environment(router)
    }
}

#Preview {
    MainView(currentSection: .constant(.main))
        .environment(User())
}
