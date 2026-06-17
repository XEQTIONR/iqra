//
//  InstructorLanguageFormView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-31.
//

import SwiftUI

struct InstructorLanguageFormView: View {
    
    @Environment(Router.self) private var router
    @Bindable var settings: InstructorSettings
    @State private var showOptions: Bool = false
    

    private var allLanguages: Set<String> {
        let names = Locale.LanguageCode.isoLanguageCodes.compactMap { code in
            Locale.current.localizedString(forLanguageCode: code.identifier)
        }
        return Set(names)
    }

    private func toggleLanguage(_ language: String) {
//
        if !settings.languages.contains(language) {
            settings.languages.insert(language)
        } else {
            settings.languages.remove(language)
        }
    }
    
    
    var body: some View {
        VStack {
                Text("Signup to teach")
                    .font(.title)
                    .padding(.top, 50)
                
                Spacer()
                    .frame(height: 50)
                
                VStack(spacing: 50) {
                    Text("What languages do you want to teach in ?")
                        .font(.title3)
                    
                    VStack(spacing: 8) {
                        Text("Languages")
                            .font(.headline)
                        
                        Button {
                            showOptions = true
                        } label: {
                            Text("\(settings.languages.count) selected")
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.all, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color.gray, lineWidth: 1.5)
                                )
                        }
                        .tint(.primary)
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showOptions) {
                        NavigationStack {
                            List {
                                ForEach(allLanguages.sorted(), id: \.self) { language in
                                    Button {
                                        toggleLanguage(language)
                                    } label: {
                                        HStack {
                                            Text(language)
                                            Spacer()
                                            if settings.languages.contains(language) {
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(.blue)
                                            }
                                        }
                                    }
                                    .tint(.primary)
                                }
                            }
                            .listStyle(.plain)
                            .navigationTitle("Languages")
                        }
                    }
                    .padding(.all, 0)
                    
                    
                    Spacer()
                    
                    Button {
                        router.push(.instructorCourseTypeForm(settings))
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
                        .background(settings.languages.isEmpty ? .gray.opacity(0.5) : .blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(settings.languages.isEmpty)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
                    
                }
                
               
            }
    }
}

#Preview {
    InstructorLanguageFormView(settings: InstructorSettings())
        .environment(Router())
}
