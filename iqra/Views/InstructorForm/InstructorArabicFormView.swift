//
//  InstructorArabicFormView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-31.
//

import SwiftUI

struct InstructorArabicFormView: View {
    @State private var selectedAnswers: [String: String] = [:]
    @State private var activeKey: String?
    
    let questions: [String: [String]] = [
        "Reading" : [
            "I cannot read Arabic",
            "I can read Arabic with harakat/tashkeel",
            "I can read Arabic with or without harakat/tashkeel",
        ],
        
        "Speaking" : [
            "I cannot speak Arabic",
            "I can speak Arabic words but I do not understand them",
            "I can speak and I understand Modern Standard Arabic (MSA) / Fusha",
            "I can speak and I understand multiple Arabic dialects",
            "I am Arab, I speak and understand most Arabic dialects"
        ],
        "Writing" : [
            "I can write in Arabic",
            "I cannot write in Arabic"
        ]
    ]
    
    var body: some View {
        NavigationStack {
            
            VStack {
                Text("Signup to teach")
                    .font(.title)
                    .padding(.top, 50)
                
                Spacer()
                    .frame(height: 50)
                
                VStack(spacing: 50) {
                    Text("What is your Arabic proficiency?")
                        .font(.title3)
                    
                    ForEach(questions.keys.sorted(), id: \.self) { key in
                        let options = questions[key] ?? []
                        let selection = Binding(
                            get: { selectedAnswers[key] ?? options.first ?? "" },
                            set: { selectedAnswers[key] = $0 }
                        )
                        
                        VStack(spacing: 8) {
                            Text(key)
                                .font(.headline)
                            
                            Button {
                                activeKey = key
                            } label: {
                                Text(selection.wrappedValue)
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
                    }
                    .confirmationDialog(
                        activeKey ?? "",
                        isPresented: Binding(
                            get: { activeKey != nil },
                            set: { if !$0 { activeKey = nil } }
                        ),
                        titleVisibility: .visible
                    ) {
                        if let activeKey, let options = questions[activeKey] {
                            ForEach(options, id: \.self) { option in
                                Button(option) {
                                    selectedAnswers[activeKey] = option
                                }
                            }
                        }
                    }
                    
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
}

#Preview {
    InstructorArabicFormView()
}
