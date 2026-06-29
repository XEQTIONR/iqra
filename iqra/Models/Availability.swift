//
//  Availability.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-17.
//

import Foundation


let MINS_PER_HR = 60
let SECS_PER_MIN = 60
let SECS_PER_HR = MINS_PER_HR * SECS_PER_MIN
let DAYS_PER_WEEK = 7

// First, create a date formatter that can handle your date format
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
    return formatter
}()

// Your struct with custom decoding/encoding for dates
struct Availability: Codable {
    var id: Int
    var instructorId: Int
    var startAt: Date
    var endAt: Date?  // ← MADE OPTIONAL
    var timezone: TimeZone
    var mon: [Int]?
    var tue: [Int]?
    var wed: [Int]?
    var thu: [Int]?
    var fri: [Int]?
    var sat: [Int]?
    var sun: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case instructorId = "instructor_id"
        case startAt = "start_at"
        case endAt = "end_at"
        case timezone
        case mon
        case tue
        case wed
        case thu
        case fri
        case sat
        case sun
    }
    
    public var toDictionary: [Day: [Int]] {
        var dict : [Day: [Int]] = [:]
        let days = Day.allCases.map{ $0.rawValue }
        
        for property in Mirror(reflecting: self).children {
            guard let label = property.label else { continue }
            guard days.contains(label) else { continue }
            guard let currentDay: Day = Day.allCases.first(where: { $0.rawValue == label }) else { continue }
            
            dict[currentDay] = property.value as? [Int]
        }
        
        return dict
    }
    
    public func toDictWithTZ() -> [Day: [Date]] {
        
        var calendar = Calendar.current
        calendar.timeZone = timezone
        
        var all: [Day: [Date]] = [:]
        var allDates: [Date] = []
        var all2: [Day: [Date]] = [:]
        
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: startAt)
        let dayIndex = components.weekday!
        
        calendar.timeZone = TimeZone.current
        for (day, mins) in toDictionary {
            let index = day.calendarWeekday
            let delta = index - dayIndex
            print("\(index), \(delta)")
            var date = calendar.date(byAdding: .day, value: delta, to: startAt)!
            
            if delta < 0 {
                date = calendar.date(byAdding: .day, value: DAYS_PER_WEEK, to: date)!
            }
            
            let slots: [Date] = mins.map{ calendar.date(byAdding: .minute, value: $0, to: date)! }
            
            for slot in slots {
                
                let comps = calendar.dateComponents([.weekday], from: slot)
                
                let d = Day.allCases.first(where: { $0.calendarWeekday == comps.weekday })!
                
                allDates.append(slot)
                
                all[d, default: []].append(slot)
                
                
                let c = calendar.dateComponents([.weekday], from: slot)
                let e = Day.allCases.first(where: { $0.calendarWeekday == c.weekday })!
                
                all2[e, default: []].append(slot)
            }
        }
        
        //print("ALL DATES: ", allDates)
        //print("DATES:", all)
        //print("SLOTTED DATES:", all2)
        
        
        return all2
    }
    
    // Custom decoding to handle the date strings
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        instructorId = try container.decode(Int.self, forKey: .instructorId)
        mon = try container.decodeIfPresent([Int].self, forKey: .mon)
        tue = try container.decodeIfPresent([Int].self, forKey: .tue)
        wed = try container.decodeIfPresent([Int].self, forKey: .wed)
        thu = try container.decodeIfPresent([Int].self, forKey: .thu)
        fri = try container.decodeIfPresent([Int].self, forKey: .fri)
        sat = try container.decodeIfPresent([Int].self, forKey: .sat)
        sun = try container.decodeIfPresent([Int].self, forKey: .sun)
        
        // Decode start date (required)
        let startDateString = try container.decode(String.self, forKey: .startAt)
        guard let startDate = dateFormatter.date(from: startDateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .startAt,
                in: container,
                debugDescription: "Invalid date format: \(startDateString)"
            )
        }
        self.startAt = startDate
        
        // Decode end date (optional)
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
        
        do {
            let tzStr = try container.decode(String.self, forKey: .timezone)
            timezone = TimeZone(identifier: tzStr)!
        } catch {
            throw DecodingError.dataCorruptedError(
                forKey: .timezone,
                in: container,
                debugDescription: "Invalid timezone")
        }
        
    }
    
    // Custom encoding to convert Date back to string
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(instructorId, forKey: .instructorId)
        try container.encodeIfPresent(mon, forKey: .mon)
        try container.encodeIfPresent(tue, forKey: .tue)
        try container.encodeIfPresent(wed, forKey: .wed)
        try container.encodeIfPresent(thu, forKey: .thu)
        try container.encodeIfPresent(fri, forKey: .fri)
        try container.encodeIfPresent(sat, forKey: .sat)
        try container.encodeIfPresent(sun, forKey: .sun)
        
        // Convert start date to string (required)
        let startDateString = dateFormatter.string(from: startAt)
        try container.encode(startDateString, forKey: .startAt)
        
        // Convert end date to string (optional)
        if let _ = endAt {
            let endDateString = dateFormatter.string(from: endAt!)
            try container.encode(endDateString, forKey: .endAt)
        }
        // If endDate is nil, don't encode it at all
        
        try container.encode(timezone.identifier, forKey: .timezone)
    }
}
