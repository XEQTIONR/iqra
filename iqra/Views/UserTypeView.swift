//
//  UserTypeView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI

struct UserTypeView: View {
    var body: some View {
        VStack {
            VStack {
                Text("What do you want to do?")
                Button(action: { print("Clicked") }) {
                    Text("Learn")
                        .frame(width: 400)
                }
                .buttonStyle(.bordered)

                Button(action: { print("Clicked") }) {
                    Text("Teach")
                        .frame(width: 400)
                }
                .buttonStyle(.bordered)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//
//var body: some View {
//    VStack {
//        Button("User") {
//        }
//        .frame(width: 600)
//        .buttonStyle(.borderedProminent)
//        .background(Color.red.opacity(0.3))  // See button bounds
//        
//        Button("Admin") {
//        }
//        .frame(width: 600)
//        .buttonStyle(.borderedProminent)
//        .background(Color.blue.opacity(0.3))  // See button bounds
//    }
//    .frame(maxWidth: .infinity, maxHeight: .infinity)
//    .background(Color.green.opacity(0.2))  // See VStack bounds
//}

#Preview {
    UserTypeView()
}
