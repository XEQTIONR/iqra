//
//  CourseSignupConfirmView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-17.
//

import SwiftUI
import UserNotifications


struct EnrollmentFormData: Codable {
    var schedule: [Day: Int]
    var startAt: Date
    var endAt: Date? = nil
    
    enum CodingKeys: String, CodingKey {
        case schedule
        case startAt = "start_at"
        case endAt = "end_at"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(schedule, forKey: .schedule)
        try container.encode(dateFormatter.string(from: startAt), forKey: .startAt)
        try container.encodeIfPresent((endAt != nil) ? dateFormatter.string(from: endAt!) : nil, forKey: .endAt)
    }
    
    init (schedule: [Day: Int], startAt: Date, endAt: Date? = nil) {
        self.schedule = schedule
        self.startAt = startAt
        self.endAt = endAt
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
        
        let endDateString = try container.decodeIfPresent(String.self, forKey: .endAt)
        
        if endDateString != nil {
            guard let endDate = dateFormatter.date(from: endDateString!) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .endAt,
                    in: container,
                    debugDescription: "Invalid date format: \(endDateString!)"
                )
            }
            self.endAt = endDate
        }
        
    }
}

struct CourseSignupConfirmView: View {
    
    var format: CourseFormat
    var course: Course
    var schedule: [Day: Int]
    var startDate: Date
    var endDate: Date?
    
    @Environment(Router.self) private var router
    @Environment(User.self) private var appUser
    
    var body: some View {
        VStack {
            Text("This is it!")
            Button("Submit") {
                print("format:", format.id!)
                print("schedule:", schedule)
                
                let input = EnrollmentFormData(schedule: schedule, startAt: startDate)
                
                Task {
                    do {
                        let (data, _, ok) = try await RequestService.request(
                            "http://localhost:8000/api/enrollments/\(format.id!)",
                            method: "POST",
                            headers: RequestService.authJsonHeaders,
                            body: try JSONEncoder().encode(input)
                        )
                        
                        print ("ok:", ok)
                        print("API RESPONSE DATA:")
                        print(String(data: data, encoding: .utf8)!)
                    
                    
                        let enrollment = try RequestService.apiUnwrapData(type: Enrollment.self, from: data)

                        if let firstClass = enrollment.sessionDates(
                            start: enrollment.startAt,
                            end: enrollment.endAt
                        ).first {
                            print("First enrollment:")
                            print(firstClass)
                            
                            let reminderDate = Date().addingTimeInterval(10)
                            
                            print("Reminder date:")
                            print(reminderDate)

                            let studentId = appUser.id ?? enrollment.user?.id
                            let instructorId = course.instructor!.id

                            print("Reminder payload studentId:", studentId as Any, "instructorId:", instructorId as Any)

                            await scheduleClassReminder(
                                at: reminderDate,
                                courseTitle: course.title,
                                studentId: studentId,
                                instructorId: instructorId
                            )
                        }

                        await MainActor.run {
                            router.popToRoot()
                            router.presentToast("Enrollment successful")
                        }
                    } catch {
                        print("ERROR:", error)
                        await MainActor.run {
                            router.presentToast("Enrollment failed")
                        }
                    }
                }
            }
        }
    }

    private func scheduleClassReminder(
        at date: Date,
        courseTitle: String,
        studentId: Int?,
        instructorId: Int?
    ) async {
        guard date > Date() else { return }

        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = courseTitle
            content.body = "Your class starts in 5 minutes"
            content.sound = .default
            content.categoryIdentifier = AppNotificationDelegate.classReminderCategoryId
            content.userInfo = [
                "studentId": studentId.map(String.init) ?? "0",
                "instructorId": instructorId.map(String.init) ?? "0"
            ]

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: date
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "class-reminder-\(date.timeIntervalSince1970)",
                content: content,
                trigger: trigger
            )

            try await center.add(request)
        } catch {
            print("Failed to schedule class reminder:", error)
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
    .environment(Router())
    .environment(User())
}
