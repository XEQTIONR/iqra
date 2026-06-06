//
//  InstructorArabicFormView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-31.
//

import SwiftUI

struct InstructorArabicFormView: View {
    
    @State private var settings = InstructorSettings()
    
    private var readingSelection: Binding<String> {
        Binding(
            get: { settings.reading.label },
            set: { label in
                if let level = ReadingLevel.allCases.first(where: { $0.label == label }) {
                    settings.reading = level
                }
            }
        )
    }
    
    private var speakingSelection: Binding<String> {
        Binding(
            get: { settings.speaking.label },
            set: { label in
                if let level = SpeakingLevel.allCases.first(where: { $0.label == label }) {
                    settings.speaking = level
                }
            }
        )
    }
    
    private var writingSelection: Binding<String> {
        Binding(
            get: { settings.writing.label },
            set: { label in
                if let level = WritingLevel.allCases.first(where: { $0.label == label }) {
                    settings.writing = level
                }
            }
        )
    }

    var body: some View {
        VStack {
            Text("Signup to teach")
                .font(.title)
                .padding(.top, 50)
            
            Spacer()
                .frame(height: 50)
            
            VStack(spacing: 50) {
                Text("What is your Arabic proficiency?")
                    .font(.title3)
                
                ProficiencyPicker(
                    title: "Reading",
                    options: ReadingLevel.allCases.map(\.label),
                    selection: readingSelection
                )
                
                ProficiencyPicker(
                    title: "Speaking",
                    options: SpeakingLevel.allCases.map(\.label),
                    selection: speakingSelection
                )
                
                ProficiencyPicker(
                    title: "Writing",
                    options: WritingLevel.allCases.map(\.label),
                    selection: writingSelection
                )
                
                Spacer()
                
                NavigationLink {
                    InstructorLanguageFormView()
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
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.bottom, 20)
            }
        }
    }
}

private struct ProficiencyPicker: View {
    let title: String
    let options: [String]
    @Binding var selection: String
    
    @State private var showOptions = false
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
            
            Button {
                showOptions = true
            } label: {
                Text(selection)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.all, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.gray, lineWidth: 1.5)
                    )
            }
            .tint(.primary)
            .confirmationDialog(title, isPresented: $showOptions, titleVisibility: .visible) {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    InstructorArabicFormView()
        .environment(User())
}
