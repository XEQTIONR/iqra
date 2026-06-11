//
//  CourseForm.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-07.
//

import SwiftUI

struct CourseFormData: Codable {
    var title: String
    var description: String
    var image: String
    var video: String
    var difficulty: Difficulty
    var category: CourseCategory
    var length_type: LengthType
    var age_groups: [AgeGroup]
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case image
        case video
        case difficulty
        case category
        case length_type
        case age_groups
    }
}

struct CourseForm: View {
    
    var onComplete: ((_ course: Course) -> Void)? = nil
    
    @State private var formData = CourseFormData(
        title: "",
        description: "",
        image: "",
        video: "",
        difficulty: .beginner,
        category: .reading,
        length_type: .fixed,
        age_groups: []
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
        
        switch formData.age_groups.count {
            case 0:
            return "None"
        case 1:
            return getLabel(formData.age_groups[0])
        case 4:
            return "All ages"
        default:
            return "\(formData.age_groups.map(getLabel).joined(separator: ", "))"
        }
    }

    private func toggleAgeGroup(_ ageGroup: AgeGroup) {
        if formData.age_groups.contains(ageGroup) {
            formData.age_groups.removeAll { $0 == ageGroup }
        } else {
            formData.age_groups.append(ageGroup)
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
            
            Picker("Course Length", selection: $formData.length_type) {
                ForEach(LengthType.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                }
            }
            
            ageGroupsLink
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
                    
                    if formData.age_groups.contains(ageGroup) {
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
