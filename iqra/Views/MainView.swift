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

    var body: some View {
        NavigationStack {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action here
                    }) {
                        Image(systemName: "bell.badge")
                            .renderingMode(.original)
                    }
                }
            }
        }
    }
}

#Preview {
    MainView(currentSection: .constant(.main))
        .environment(User())
}
