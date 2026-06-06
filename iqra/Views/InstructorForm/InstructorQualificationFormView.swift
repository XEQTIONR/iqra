//
//  InstructorFormView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-31.
//

import SwiftUI

struct InstructorQualificationFormView: View {
    
    @State private var settings = InstructorSettings()
    
    let titles: [(label: String, value: Title)] = [
        ("Hafiz - حفيظ ", .hafiz),
        ("Hujjat al Islam - حجة الإسلام", .hujjat),
        ("Qari - قارئ", .qari),
        ("Imaam - إمام", .imaam),
        ("'Alim - عليم", .alim),
        ("Mufti - مفتي", .mufti),
        ("Ayatollah - عيت الله", .ayatollah),
    ]
    
    var body: some View {
        VStack {
                Text("Signup to teach")
                    .font(.title)
                    .padding(.top, 50)
                
                Spacer()
                    .frame(height: 50)
                
                VStack(spacing: 15) {
                    Text("Select all the titles that apply to you")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .padding(.bottom, 50)
                    ForEach(titles, id: \.label) { item in
                        VStack() {
                            Text(item.label)
                                .foregroundStyle(settings.titles.contains(item.value) ? .blue : .primary)
                                .padding(.all, 10)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(settings.titles.contains(item.value) ? .blue : .gray, lineWidth: 1.5)
                                )
                                .padding(.horizontal)
                                
                        }
                        .onTapGesture {
                            if (settings.titles.contains(item.value)) {
                                settings.titles.remove(item.value)
                            } else {
                                settings.titles.insert(item.value)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Spacer()
                    
                    NavigationLink {
                        InstructorFormCompleteView()
                    } label: {
                        ZStack {
                            Text(settings.titles.count == 0 ? "Skip" : "Continue")
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .padding(.trailing, 20)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(settings.titles.count == 0 ? 0.001 : 1), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: settings.titles.count == 0 ? 1 : 0)
                        )
                        
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                        
                    }
                    .foregroundStyle(settings.titles.count == 0 ? .blue : .white)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
                    
                }
                
               
            }
    }
}

#Preview {
    InstructorQualificationFormView()
}
