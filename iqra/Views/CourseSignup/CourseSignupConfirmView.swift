//
//  CourseSignupConfirmView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-17.
//

import SwiftUI


struct EnrollmentFormData: Codable {
    var schedule: [Day: Int]
    var startAt: Date
    
    enum CodingKeys: String, CodingKey {
        case schedule
        case startAt = "start_at"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(schedule, forKey: .schedule)
        try container.encode(dateFormatter.string(from: startAt), forKey: .startAt)
    }
    
    init (schedule: [Day: Int], startAt: Date) {
        self.schedule = schedule
        self.startAt = startAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        
        schedule = try container.decode([Day: Int].self, forKey: .schedule)
        // Decode start date
        let startDateString = try container.decode(String.self, forKey: .startAt)
        guard let startDate = dateFormatter.date(from: startDateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .startAt,
                in: container,
                debugDescription: "Invalid date format: \(startDateString)"
            )
        }
        startAt = startDate
    }
}

struct CourseSignupConfirmView: View {
    
    var format: CourseFormat
    var course: Course
    var schedule: [Day: Int]
    var startDate: Date
    
    
    var body: some View {
        Text("This is it!")
        
        Button("Submit") {
            print("format:", format.id!)
            print("schedule:", schedule)
            
            let input = EnrollmentFormData(schedule: schedule, startAt: startDate)
            
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
                
                do {
                    let enrollment = try RequestService.apiUnwrapData(type: Enrollment.self, from: data)
                    print("enrollment:", enrollment)
                } catch {
                    print("ERROR:", error)
                }
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
            totalLessons: 10,
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
        ],
        
        startDate: Date(),
    )
}
