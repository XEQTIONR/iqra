//
//  CourseSignupConfirmView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-17.
//

import SwiftUI


struct EnrollmentFormData: Codable {
    var schedule: [Day: Int]
}

struct CourseSignupConfirmView: View {
    
    var format: CourseFormat
    var course: Course
    var schedule: [Day: Int]
    
    
    var body: some View {
        Text("This is it!")
        
        Button("Submit") {
            print("format:", format.id!)
            print("schedule:", schedule)
            
            let input = EnrollmentFormData(schedule: schedule)
            
            Task {
                let (data, _, ok) = try await RequestService.request(
                    "http://localhost:8000/api/enrollments/\(format.id!)",
                    method: "POST",
                    headers: RequestService.authJsonHeaders,
                    body: try JSONEncoder().encode(input)
                )
                
                print ("ok:", ok)
                print("API RESPONSE DATA:")
                print(String(data: data, encoding: .utf8)!)
            }
        }
    }
}

#Preview {
    CourseSignupConfirmView(
        format: CourseFormat(
            title: "Course Format",
            description: "The description",
            unit: .lesson,
            lessonLength: 60,
            lessonsPerWeek: 2,
            price: 100,
            billingCycles: 4
        ),
        
        course: Course (
            title: "Course Title",
            description: "Description",
            image: "",
            video: "",
            difficulty: .beginner,
            category: .reading,
            lengthType: .fixed,
            ageGroups: [.kids,.teens],
            isPublished: false,
            formats: [],
            totalLessons: 10,
        ),
        
        schedule: [
            .mon: 600,
            .wed: 720
        ]
    )
}
