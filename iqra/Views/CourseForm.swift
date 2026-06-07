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

    
    var body: some View {
        NavigationStack() {
            VStack(alignment: .leading, spacing: 25) {
                VStack(alignment: .leading) {
                    Text("Course Name")
                    TextField("Beginer Arabic reading course", text: .constant(""))
                }
                
                VStack(alignment: .leading) {
                    Text("Course Level")
                    Picker("Course Level", selection: $difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }.pickerStyle(.segmented)
                }
                
                VStack(alignment: .leading) {
                    Text("Course Category")
                    Picker("Course Category", selection: $category) {
                        ForEach(CourseCategory.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }.pickerStyle(.segmented)
                }
                
                VStack(alignment: .leading) {
                    Text("Description")
                    TextEditor(text: $description)
                }
                
                Spacer()
                
            }
            .frame(maxWidth: .infinity)
            .padding()
            .navigationTitle("Create new course")
            
            
        }
    }
}

#Preview {
    CourseForm()
}
