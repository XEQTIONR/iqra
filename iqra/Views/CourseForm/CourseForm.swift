//
//  CourseForm.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-07.
//

import SwiftUI

struct CourseForm: View {
    
    var onComplete: ((_ course: Course) -> Void)? = nil
    
    @State private var formData = Course(
        title: "",
        description: "",
        image: "",
        video: "",
        difficulty: .beginner,
        category: .reading,
        lengthType: .fixed,
        ageGroups: [],
        isPublished: false
    )
    @State private var showAgeSelector: Bool = false
    @State private var router = Router()
    
    
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
        
        switch formData.ageGroups.count {
        case 0:
            return "None"
        case 1:
            return getLabel(formData.ageGroups[0])
        case 4:
            return "All ages"
        default:
            return "\(formData.ageGroups.map(getLabel).joined(separator: ", "))"
        }
    }

    private func toggleAgeGroup(_ ageGroup: AgeGroup) {
        if formData.ageGroups.contains(ageGroup) {
            formData.ageGroups.removeAll { $0 == ageGroup }
        } else {
            formData.ageGroups.append(ageGroup)
        }
    }
    
    private var titleSection: some View {
        Section(header: Text("Title")) {
            TextField("Learn to read the Quran in Arabic", text: $formData.title)
        }
    }
    
    private var detailsSection: some View {
        Section(header: Text("Details")) {
            Picker("Course Level", selection: $formData.difficulty) {
                ForEach(Difficulty.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                }
            }
            
            Picker("Course Category", selection: $formData.category) {
                ForEach(CourseCategory.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                }
            }
            
            Picker("Course Length", selection: $formData.lengthType) {
                ForEach(LengthType.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                }
            }
            
            ageGroupsLink
            
            Toggle(isOn: $formData.isPublished) {
                Text("Publish")
            }
        }
    }
    
    private var ageGroupsLink: some View {
        NavigationLink {
            ageGroupsList
        } label: {
            HStack {
                Label("Age groups", systemImage: "gear")
                    .labelStyle(.titleOnly)
                
                Spacer()
                
                Text(selectedLabel())
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var ageGroupsList: some View {
        List {
            ForEach(AgeGroup.allCases, id: \.self) { ageGroup in
                HStack {
                    Text(getLabel(ageGroup))
                    Spacer()
                    
                    if formData.ageGroups.contains(ageGroup) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .background(.white.opacity(0.01))
                .onTapGesture {
                    toggleAgeGroup(ageGroup)
                }
            }
        }
        .navigationTitle(Text("Select age groups"))
    }
    
    private var descriptionSection: some View {
        Section(header: Text("Description")) {
            TextEditor(text: $formData.description)
                .frame(minHeight: 100)
        }
    }
    
    private var continueRow: some View {
        ZStack {
            NavigationLink {
                CourseIntroVideoForm(
                    formData: $formData,
                    onComplete: onComplete
                )
            } label: {
                EmptyView()
            }
            .opacity(0)

            HStack {
                Spacer()
                Text("Continue")
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
        }
        .listRowBackground(Color.blue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                titleSection
                detailsSection
                descriptionSection
                continueRow
            }
            .navigationTitle("Create new course")
        }
    }
}

#Preview {
    CourseForm()
}
