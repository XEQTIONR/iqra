//
//  InstructorArabicFormView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-31.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var completion: (() -> Void)? = nil
}

struct InstructorArabicFormView: View {
    
    let completion: (() -> Void)?
    
    @State private var router = Router()
    
    @State private var settings = InstructorSettings()
    
    private var readingSelection: Binding<String> {
        Binding(
            get: { readingLabel(settings.reading) },
            set: { label in
                if let level = ReadingLevel.allCases.first(where: { readingLabel($0) == label }) {
                    settings.reading = level
                }
            }
        )
    }
    
    private var speakingSelection: Binding<String> {
        Binding(
            get: { speakingLabel(settings.speaking) },
            set: { label in
                if let level = SpeakingLevel.allCases.first(where: { speakingLabel($0) == label }) {
                    settings.speaking = level
                }
            }
        )
    }
    
    private var writingSelection: Binding<String> {
        Binding(
            get: { writingLabel(settings.writing) },
            set: { label in
                if let level = WritingLevel.allCases.first(where: { writingLabel($0) == label }) {
                    settings.writing = level
                }
            }
        )
    }
    
    private func readingLabel(_ level: ReadingLevel) -> String {
        switch level {
        case .no: return "I cannot read Arabic"
        case .withHarakat: return "I can read Arabic with harakat/tashkeel"
        case .withoutHarakat: return "I can read Arabic with or without harakat/tashkeel"
        }
    }
    
    private func speakingLabel(_ level: SpeakingLevel) -> String {
        switch level {
        case .no: return "I cannot speak Arabic"
        case .wordsOnly: return "I can speak Arabic words but I do not understand them"
        case .MSA: return "I can speak and I understand Modern Standard Arabic (MSA) / Fusha"
        case .multiple: return "I can speak and I understand multiple Arabic dialects"
        case .native: return "I am Arab, I speak and understand most Arabic dialects"
        }
    }
    
    private func writingLabel(_ level: WritingLevel) -> String {
        switch level {
        case .no: return "I cannot write in Arabic"
        case .yes: return "I can write in Arabic"
        }
    }

    var body: some View {
        NavigationStack(path: $router.path) {
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
                        options: ReadingLevel.allCases.map(readingLabel),
                        selection: readingSelection
                    )
                    
                    ProficiencyPicker(
                        title: "Speaking",
                        options: SpeakingLevel.allCases.map(speakingLabel),
                        selection: speakingSelection
                    )
                    
                    ProficiencyPicker(
                        title: "Writing",
                        options: WritingLevel.allCases.map(writingLabel),
                        selection: writingSelection
                    )
                    
                    Spacer()
                    
                    Button {
                        if (settings.reading == .no
                            && settings.writing == .no
                            && settings.speaking == .no
                        ) {
                            router.push(.instructorUnqualified)
                        } else {
                            router.push(.instructorLanguageForm(settings))
                        }
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
            .navigationDestination(for: Route.self) { route in
                route.destination
                    .environment(\.completion, completion)
                    .environment(router)
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
    InstructorArabicFormView(completion: nil)
        .environment(User())
        .environment(Router())
}
