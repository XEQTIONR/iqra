//
//  InstructorFormView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-31.
//

import SwiftUI

struct InstructorCourseTypeFormView: View {
    
    @Environment(Router.self) private var router
    @Bindable var settings: InstructorSettings
    
    let labels: [CourseCategory: String] = [
        .reading: "Quran recitation, reading and memorization",
        .qScience: "Quran Sciences",
        .hScience: "Hadith Sciences",
        .calligraphy: "Arabic / Quranic Calligraphy",
    ]
    
    var body: some View {
        VStack {
                Text("Signup to teach")
                    .font(.title)
                    .padding(.top, 50)
                
                Spacer()
                    .frame(height: 50)
                
                VStack(spacing: 15) {
                    Text("What kind of courses \n do you want to teach?")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .padding(.bottom, 50)
                    
                    VStack(spacing: 15) {
                        ForEach(CourseCategory.allCases, id: \.self) { category in
                            let isSelected = settings.courseCategories.contains(category)

                            Text(labels[category] ?? category.rawValue)
                                .padding(.all, 10)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(isSelected ? Color.blue : Color.primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(isSelected ? Color.blue : Color.gray, lineWidth: 1.5)
                                )
                                .padding(.horizontal)
                                .contentShape(RoundedRectangle(cornerRadius: 12))
                                .onTapGesture {
                                    if isSelected {
                                        settings.courseCategories.remove(category)
                                    } else {
                                        settings.courseCategories.insert(category)
                                    }
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    Button {
//                        if settings.courseCategories.contains(.islamic) {
//                            router.push(.instructorMuslimForm(settings))
//                        } else {
                            router.push(.instructorFormComplete(settings))
//                        }
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
                        .background(settings.courseCategories.count == 0 ? .gray.opacity(0.5) : .blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(settings.courseCategories.count == 0)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
                    
                }
                
               
            }
    }
}

#Preview {
    InstructorCourseTypeFormView(settings: InstructorSettings())
        .environment(Router())
}
