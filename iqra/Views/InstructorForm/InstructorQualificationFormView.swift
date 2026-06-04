//
//  InstructorFormView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-31.
//

import SwiftUI

struct InstructorQualificationFormView: View {
    
    let titles = [
        "Hafiz - حفيظ ",
        "Hujjat al Islam - حجة الإسلام",
        "Qari - قارئ",
        "Imaam - إمام",
        "'Alim - عليم",
        "Mufti - مفتي",
        "Ayatollah - عيت الله",
    ]
    
    var body: some View {
        NavigationStack {
            
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
                    ForEach(titles, id: \.self) { title in
                        VStack() {
                            Text(title)
                                .padding(.all, 10)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color.gray, lineWidth: 1.5)
                                )
                                .padding(.horizontal)
                                
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Spacer()
                    
                    NavigationLink {
                        InstructorArabicFormView()
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
    InstructorQualificationFormView()
}
