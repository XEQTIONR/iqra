//
//  CourseForm.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-07.
//

import SwiftUI

struct CourseForm: View {
    
    @State private var difficulty: Difficulty = .beginner
    @State private var category: CourseCategory = .reading
    @State private var description: String = ""
    @State private var title: String = ""
    @State private var lengthType: LengthType = .fixed
    @State private var ageGroups: [AgeGroup] = []
    @State private var showAgeSelector: Bool = false
    
    
    private func getLabel(_ group: AgeGroup) -> String {
        switch group {
        case .kids:
            return "<13"
        case .teens:
            return "13-19"
        case .youngAdults:
            return "20-55"
        case .seniors:
            return "55+"
        }
    }
    
    private func selectedLabel() -> String {
        
        switch ageGroups.count {
            case 0:
            return "None"
        case 1:
            return getLabel(ageGroups[0])
        case 4:
            return "All ages"
        default:
            return "\(ageGroups.map(getLabel).joined(separator: ", "))"
        }
    }

    
    var body: some View {
        NavigationStack() {
            Form() {
                Section(header: Text("Title")) {
                    TextField("Learn to read the Quran in Arabic", text: $title)
                }
                
                
                
                
                Section(header: Text("Details")) {
                    Picker("Course Level", selection: $difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                    
                    
                    Picker("Course Category", selection: $category) {
                        ForEach(CourseCategory.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                    
                    Picker("Course Length", selection: $lengthType) {
                        ForEach(LengthType.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                    
                    VStack {
                        HStack {
                            NavigationLink {
                                List {
                                    ForEach(AgeGroup.allCases, id: \.self) { ageGroup in
                                        HStack {
                                            Text(getLabel(ageGroup))
                                            Spacer()
                                            
                                            if ageGroups.contains(ageGroup) {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .background(.white.opacity(0.01))
                                        .onTapGesture {
                                            if ageGroups.contains(ageGroup) {
                                                ageGroups.removeAll { $0 == ageGroup }
                                            } else {
                                                ageGroups.append(ageGroup)
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Label("Age groups", systemImage: "gear") // Visual Label
                                        .labelStyle(.titleOnly)
                                    
                                    Spacer()
                                    
                                    Text(selectedLabel())
                                        .foregroundColor(.gray)
                                }
                            }
                            
                        }
//                        .sheet(isPresented: $showAgeSelector) {
//                            List {
//                                ForEach(AgeGroup.allCases, id: \.self) { ageGroup in
//                                    HStack {
//                                        Text(ageGroup.rawValue)
//                                    }
//                                }
//                            }
//                        }
                        
                    }
                    
                     
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
                
                
                
            }
//            .frame(maxWidth: .infinity)
//            .padding()
            .navigationTitle("Create new course")
            
            
        }
    }
}

#Preview {
    CourseForm()
}
