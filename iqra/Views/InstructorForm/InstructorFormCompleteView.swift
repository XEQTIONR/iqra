//
//  InstructorFormCompleteView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-04.
//

import SwiftUI

struct InstructorFormCompleteView: View {
    
    @Bindable var settings: InstructorSettings

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
            Text("Creating your instructor profile...")
            Text(settings.description)
        }
    }
}

#Preview {
    InstructorFormCompleteView(settings: InstructorSettings())
}
