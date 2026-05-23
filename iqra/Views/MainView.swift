//  MainView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI
import SwiftData


struct MainView: View {
    
    @State var currentSection: ContentSection = .intro
    
    var body: some View {
        NavigationStack {
            TabView {
                Tab("Explore", systemImage: "magnifyingglass") {
                    ExploreView()
                }
    //            Tab("Calendar", systemImage: "calendar") {
    //                CalendarView()
    //            }
                Tab("Lessons", systemImage: "graduationcap") {
                    UserTypeView()
                }
                Tab("Settings", systemImage: "gearshape") {
                    SettingsView()
                }
                
            }
            .navigationTitle("Explore")

//            .navigation
            .toolbar {
                // Item on the top right
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Circle().fill(Color.red).frame(width: 30, height: 30)
                        Text("John Doe")
                            .font(.subheadline)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action here
                    }) {
                        Image(systemName: "bell.badge")
                            .renderingMode(.original)
                    }.padding(.trailing)
                }
                
            }
            
        }
        
    }
}

#Preview {
    MainView()

}
