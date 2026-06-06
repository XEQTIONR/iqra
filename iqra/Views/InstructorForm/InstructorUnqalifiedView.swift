//
//  InstructorUnqalifiedView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-06.
//

import SwiftUI

struct InstructorUnqalifiedView: View {
    
    @Environment(Router.self) private var router
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Sorry, you are not yet \n qualified to be an instructor")
                .multilineTextAlignment(.center)
            
            Button("Back to start") {
                router.popToRoot()
            }
        }
    }
}

#Preview {
    InstructorUnqalifiedView()
        .environment(Router())
}
