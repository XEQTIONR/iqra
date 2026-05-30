//
//  SettingsView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    
    @Binding var currentSection: ContentSection
    @State private var modalOpen: Bool = false
    
    @Query private var users: [User]
    
    
    init(_ currentSection: Binding<ContentSection>) {
        self._currentSection = currentSection
    }

    let defaults = UserDefaults.standard

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        if users.count > 0 {
            Text("Settings")
            Text(users[0].name)
        } else {
            Button("Something") {
                modalOpen.toggle()
            }.sheet(isPresented:$modalOpen) {
                
                
                LoginView(completion: {() -> Void in
                    modalOpen = false
                })
            }
        }
    }
}

#Preview {
    SettingsView(.constant(.main))
}
