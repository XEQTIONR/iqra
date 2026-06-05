//
//  InstructorFormCompleteView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-04.
//

import SwiftUI

struct InstructorFormCompleteView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ProgressView()
                Text("Creating your instructor profile...")
            }
        }
    }
}

#Preview {
    InstructorFormCompleteView()
}
