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
    
    @State var courses: [Course] = []
    @State private var selectedTab = 0

    var body: some View {
        
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
    }
}

#Preview {
    MainView(currentSection: .constant(.main))
        .environment(User())
}
