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

    
    var body: some View {
        NavigationStack() {
            Form() {
                Section(header: Text("Title")) {
                    TextField("Learn to read the Quran in Arabic", text: $formData.title)
                }

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
                    
                    VStack {
                        HStack {
                            NavigationLink {
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
                                            if formData.age_groups.contains(ageGroup) {
                                                formData.age_groups.removeAll { $0 == ageGroup }
                                            } else {
                                                formData.age_groups.append(ageGroup)
                                            }
                                        }
                                    }
                                }
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
                    }
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $formData.description)
                        .frame(minHeight: 100)
                }
                
//                Button(action: {
//                    Task {
//                        do {
//                            print(RequestService.authJsonHeaders)
//                            print(UserDefaults.standard.string(forKey: "api_token")!)
//                            let body = try JSONEncoder().encode(formData)
//                            let (data, _, ok) = try await RequestService.request(
//                                COURSES_ENDPOINT,
//                                method: "POST",
//                                headers: RequestService.authJsonHeaders,
//                                body: body
//                            )
//
//                            if ok {
//                                
//                                let course = try RequestService.apiUnwrapData(type: Course.self, from: data)
//                                print("success")
//                                onComplete?(course)
//                            } else {
//                                print("oops")
//                            }
//
//                            print(String(data: data, encoding: .utf8) ?? "no data")
//                        } catch {
//                            print("request failed: \(error)")
//                        }
//                    }
//                }) {
//                    Text("Submit")
//                        .frame(maxWidth: .infinity)
//                        .contentShape(Rectangle()) // Makes the whole row tappable
//                }
//                .listRowBackground(Color.blue)
//                .foregroundColor(.white)
                
//                NavigationLink("My Link") {
//                    CourseImage()
//                }
//                .listRowBackground(Color.blue)
//                .foregroundColor(.white)
                
                ZStack {
                    NavigationLink {
                        CourseIntroVideoForm(formData: $formData)
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
            .navigationTitle("Create new course")
        }
    }
}

#Preview {
    CourseForm()
}
