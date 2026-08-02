//
//  Enrollment.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-18.
//

import Foundation

struct Enrollment: Codable {
    var id: Int
    var startAt: Date
    var endAt: Date?
    var price: Double
    var currency: String
    var status: String
    var length: Int
    var schedule: [Day: Int]
    var format: CourseFormat?
    var user: User?
    
    enum CodingKeys: String, CodingKey {
        case id
        case startAt = "start_at"
        case endAt = "end_at"
        case price
        case currency
        case status
        case length
        case schedule
        case format
        case user
    }

    init(
        id: Int,
        startAt: Date,
        endAt: Date? = nil,
        price: Double,
        currency: String,
        status: String,
        length: Int,
        schedule: [Day: Int],
        format: CourseFormat? = nil,
        user: User? = nil
    ) {
        self.id = id
        self.startAt = startAt
        self.endAt = endAt
        self.price = price
        self.currency = currency
        self.status = status
        self.length = length
        self.schedule = schedule
        self.format = format
        self.user = user
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        price = try container.decode(Double.self, forKey: .price)
        currency = try container.decode(String.self, forKey: .currency)
        status = try container.decode(String.self, forKey: .status)
        length = try container.decode(Int.self, forKey: .length)
        schedule = try container.decode([Day: Int].self, forKey: .schedule)
        format = try container.decodeIfPresent(CourseFormat.self, forKey: .format)
        user = try container.decodeIfPresent(User.self, forKey: .user)

        // Decode start date
        let startDateString = try container.decode(String.self, forKey: .startAt)
        guard let startAt = dateFormatter.date(from: startDateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .startAt,
                in: container,
                debugDescription: "Invalid date format: \(startDateString)"
            )
        }
        self.startAt = startAt

        // Decode end date (optional / null)
        if let endDateString = try container.decodeIfPresent(String.self, forKey: .endAt) {
            guard let endDate = dateFormatter.date(from: endDateString) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .endAt,
                    in: container,
                    debugDescription: "Invalid date format: \(endDateString)"
                )
            }
            self.endAt = endDate
        } else {
            self.endAt = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(price, forKey: .price)
        try container.encode(currency, forKey: .currency)
        try container.encode(status, forKey: .status)
        try container.encode(length, forKey: .length)
        try container.encode(schedule, forKey: .schedule)
        
        let startDateString = dateFormatter.string(from: startAt)
        try container.encode(startDateString, forKey: .startAt)
        
        if let endAt {
            try container.encode(dateFormatter.string(from: endAt), forKey: .endAt)
        }
    }
    
    func hasSessionOn(_ date: Date) -> Bool {
        return sessionForDate(date) != nil
    }
    
    func sessionForDate(_ date: Date) -> Int? {
        guard let weekday = Calendar.current.dateComponents([.weekday], from: date).weekday else {
            return nil
        }
        
        for key in schedule.keys {
            if key.calendarWeekday == weekday {
                return schedule[key]
            }
        }
        
        return nil
    }
    
    func sessionDates(start: Date, end: Date?) -> [Date] {
        let calendar = Calendar.current
        let rangeStart = start
        let rangeEnd = end ?? endAt ?? calendar.date(byAdding: .month, value: 1, to: rangeStart)
        let searchStart = calendar.date(byAdding: .second, value: -1, to: rangeStart) ?? rangeStart
        var sessions: [Date] = []
        
        for (day, minutesFromMidnight) in schedule {
            var components = DateComponents()
            components.weekday = day.calendarWeekday
            components.hour = minutesFromMidnight / 60
            components.minute = minutesFromMidnight % 60

            calendar.enumerateDates(
                startingAfter: searchStart,
                matching: components,
                matchingPolicy: .nextTime
            ) { date, _, stop in
                guard let date else { return }
                
                if date >= startAt {
                    if rangeEnd == nil {
                        if date > calendar.date(byAdding: .month, value: 1, to: rangeStart)! {
                            stop = true
                            return
                        }
                    }
                    
                    else if calendar.startOfDay(for: date) > rangeEnd! {
                        stop = true
                        return
                    }
                    sessions.append(date)
                }
            }
        }

        return sessions.sorted()
    }
}

#if DEBUG
extension Enrollment {
    /// Sample enrollments with weekly sessions covering the current calendar month.
    static var previewEnrollments: [Enrollment] {
        let calendar = Calendar.current
        let now = Date()
        guard let month = calendar.dateInterval(of: .month, for: now) else { return [] }

        let instructor = User.preview

        let readingCourse = Course(
            id: 1,
            title: "Quran Reading",
            description: "Learn to read the Quran with proper tajweed.",
            image: "https://picsum.photos/600/400",
            video: "",
            difficulty: .beginner,
            category: .reading,
            lengthType: .ongoing,
            ageGroups: [.kids, .teens],
            isPublished: true,
            instructor: instructor
        )

        let tajweedCourse = Course(
            id: 2,
            title: "Tajweed Foundations",
            description: "Build a strong foundation in tajweed rules.",
            image: "https://picsum.photos/600/400",
            video: "",
            difficulty: .intermediate,
            category: .qScience,
            lengthType: .fixed,
            ageGroups: [.teens, .youngAdults],
            isPublished: true,
            instructor: instructor
        )

        let readingFormat = CourseFormat(
            id: 1,
            title: "Twice weekly",
            description: "Two 60-minute lessons per week",
            unit: .lesson,
            lessonLength: 60,
            lessonsPerWeek: 2,
            totalLessons: 16,
            price: 80,
            billingCycles: 8,
            course: readingCourse
        )

        let tajweedFormat = CourseFormat(
            id: 2,
            title: "Weekly intensive",
            description: "One 90-minute lesson per week",
            unit: .lesson,
            lessonLength: 90,
            lessonsPerWeek: 1,
            totalLessons: 12,
            price: 60,
            billingCycles: 12,
            course: tajweedCourse
        )

        return [
            Enrollment(
                id: 1,
                startAt: month.start,
                endAt: month.end,
                price: 80,
                currency: "USD",
                status: "active",
                length: 60,
                schedule: [
                    .mon: 10 * 60,       // Monday 10:00
                    .wed: 14 * 60 + 30,  // Wednesday 14:30
                ],
                format: readingFormat,
                user: User.preview
            ),
            Enrollment(
                id: 2,
                startAt: month.start,
                endAt: month.end,
                price: 60,
                currency: "USD",
                status: "active",
                length: 90,
                schedule: [
                    .tue: 16 * 60,       // Tuesday 16:00
                    .thu: 16 * 60,       // Thursday 16:00
                    .fri: 9 * 60 + 30,   // Friday 09:30
                ],
                format: tajweedFormat,
                user: User.preview
            ),
        ]
    }
}
#endif
