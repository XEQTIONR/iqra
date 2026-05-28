//
//  SettingsView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI

struct SettingsView: View {

    let defaults = UserDefaults.standard

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        if defaults.string(forKey: "userId") != nil {
            Text("Settings")
        } else {
            LoginView()
        }
    }
}

#Preview {
    SettingsView()
}
