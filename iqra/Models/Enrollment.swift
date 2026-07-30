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
    
    func sessionDates(start: Date?, end: Date?) -> [Date] {

        let calendar = Calendar.current
        let rangeStart = start ?? Date()
        let rangeEnd = end ?? endAt ?? calendar.date(byAdding: .month, value: 1, to: rangeStart)
        let searchStart = calendar.date(byAdding: .second, value: -1, to: rangeStart) ?? rangeStart
        var sessions: [Date] = []
        
        for (day, minutesFromMidnight) in schedule {
            print("IN LOOP:", day, minutesFromMidnight)
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
