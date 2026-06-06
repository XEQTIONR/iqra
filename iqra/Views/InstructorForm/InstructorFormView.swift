//
//  InstructorFormView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-31.
//

import SwiftUI

struct InstructorFormView: View {
    
    @State private var settings = InstructorSettings()
    
    var body: some View {
        VStack {
            Text("Signup to teach")
                .font(.title)
                .padding(.top, 50)

            Spacer()
                .frame(height: 150)

            VStack {
                Text("Select your gender")
                    .font(.title3)
                    .padding(.bottom, 50)

                HStack(spacing: 75) {
                    VStack {
                        Text("♂︎")
                            .font(.largeTitle)
                            .foregroundStyle(settings.gender == .male ? Color.blue : Color.primary)
                        Text("Male")
                            .foregroundStyle(settings.gender == .male ? Color.blue : Color.primary)
                    }
                    .frame(width: 100, height: 100)
                    .onTapGesture {
                        settings.gender = .male
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(settings.gender == .male ? Color.blue : Color.primary, lineWidth: 2) // Draws the rounded border
                    )
                    
                    VStack {
                        Text("♀︎")
                            .font(.largeTitle)
                            .foregroundStyle(settings.gender == .female ? Color.blue : Color.primary)
                        Text("Female")
                            .foregroundStyle(settings.gender == .female ? Color.blue : Color.primary)
                    }
                    .frame(width: 100, height: 100)
                    .onTapGesture {
                        settings.gender = .female
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(settings.gender == .female ? Color.blue : Color.primary, lineWidth: 2) // Draws the rounded border
                    )
                }
                
                Spacer()
                
                NavigationLink {
                    InstructorAgeFormView()
                } label: {
                    ZStack {
                        Text("Next")
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 20)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(settings.gender == nil ? Color.gray.opacity(0.4) : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(settings.gender == nil)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    InstructorFormView()
        .environment(User())
}
