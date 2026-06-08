//
//  ContentView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI
import SwiftData


enum ContentSection {
    case intro
    case main
}

struct ContentView: View {
    
    @State var currentSection: ContentSection
    
    init() {
        let introShown = UserDefaults.standard.bool(forKey: "intro_shown")
        if introShown {
            _currentSection = State(initialValue: .main)
        } else {
            UserDefaults.standard.set(true, forKey: "intro_shown")
            _currentSection = State(initialValue: .intro)
        }
    }
    
    var body: some View {
        switch currentSection {
            
        case .intro:
            IntroView($currentSection)
        case .main:
            MainView(currentSection: $currentSection)
        }
    }
}

#Preview {
    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
}
