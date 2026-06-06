//
//  InstructorFormView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-31.
//

import SwiftUI

struct InstructorCourseTypeFormView: View {
    
    @State private var settings = InstructorSettings()
    
    let types = [
        "Islamic & Quran courses",
        "Arabic language & calligraphy courses",
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
                        Text("Islamic & Quran courses")
                            .padding(.all, 10)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(settings.courseCategories.contains(.islamic) ? Color.blue : Color.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(settings.courseCategories.contains(.islamic) ? Color.blue : Color.gray, lineWidth: 1.5)
                            )
                            .padding(.horizontal)
                            .onTapGesture {
                                if (!settings.courseCategories.contains(.islamic)) {
                                    settings.courseCategories.insert(.islamic)
                                } else {
                                    settings.courseCategories.remove(.islamic)
                                }
                            }
                        
                        Text("Arabic language & calligraphy courses")
                            .padding(.all, 10)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(settings.courseCategories.contains(.arabic) ? Color.blue : Color.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(settings.courseCategories.contains(.arabic) ? Color.blue : Color.gray, lineWidth: 1.5)
                            )
                            .padding(.horizontal)
                            .onTapGesture {
                                if (!settings.courseCategories.contains(.arabic)) {
                                    settings.courseCategories.insert(.arabic)
                                } else {
                                    settings.courseCategories.remove(.arabic)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    NavigationLink {
                        if settings.courseCategories.contains(.islamic) {
                            InstructorMuslimFormView()
                        } else {
                            InstructorFormCompleteView()
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
    InstructorCourseTypeFormView()
}
