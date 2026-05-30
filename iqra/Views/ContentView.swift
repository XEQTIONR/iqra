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
    
    @State var currentSection: ContentSection = .intro

    var body: some View {
        
        switch currentSection {
            
        case .intro:
            IntroView($currentSection)
        case .main:
            MainView($currentSection)
        }
    }
}

#Preview {
    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
}
