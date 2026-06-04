//
//  InstructorFormView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-31.
//

import SwiftUI

struct InstructorAgeFormView: View {
    
    @State private var settings = InstructorSettings()
    
    func getEnumLabel(_ group: AgeGroup) -> String {
        
        switch group {
        case .aLessThan19:
            return "Under 19"
        case .a19To24:
            return "19-24"
        case .a25To34:
            return "25-34"
        case .a35To44:
            return "35-44"
        case .a45To54:
            return "45-54"
        case .a55plus:
            return "55+"
        }
    }
    
    let ranges = [
        "Under 19",
        "19-24",
        "25-34",
        "35-44",
        "45-54",
        "55+"
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
                    Text("How old are you")
                        .font(.title3)
                        .padding(.bottom, 50)
                    ForEach(AgeGroup.allCases, id: \.self) { group in
                        VStack() {
                            Text(getEnumLabel(group))
                                .padding(.all, 10)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(settings.ageGroup == getEnumLabel(group)  ? .blue : .primary)
                                .background(Color.blue.opacity(0.01))
                                    .onTapGesture {
                                        settings.ageGroup = getEnumLabel(group)
                                    }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(settings.ageGroup == getEnumLabel(group)  ? .blue : .gray, lineWidth: 1.5)
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
                        .background(settings.ageGroup == nil ? Color.gray.opacity(0.4) : Color.blue)
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
    InstructorAgeFormView()
}
