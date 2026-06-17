//
//  Availability.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-17.
//

import Foundation

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
    var startDate: Date
    var endDate: Date?  // ← MADE OPTIONAL
    var mon: [Int]?
    var tue: [Int]?
    var wed: [Int]?
    var thu: [Int]?
    var fri: [Int]?
    var sat: [Int]?
    var sun: [Int]?
    
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case instructorId = "instructor_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case mon
        case tue
        case wed
        case thu
        case fri
        case sat
        case sun
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
        let startDateString = try container.decode(String.self, forKey: .startDate)
        guard let startDate = dateFormatter.date(from: startDateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .startDate,
                in: container,
                debugDescription: "Invalid date format: \(startDateString)"
            )
        }
        self.startDate = startDate
        
        // Decode end date (optional)
        if let endDateString = try container.decodeIfPresent(String.self, forKey: .endDate) {
            guard let endDate = dateFormatter.date(from: endDateString) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .endDate,
                    in: container,
                    debugDescription: "Invalid date format: \(endDateString)"
                )
            }
            self.endDate = endDate
        } else {
            self.endDate = nil
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
        let startDateString = dateFormatter.string(from: startDate)
        try container.encode(startDateString, forKey: .startDate)
        
        // Convert end date to string (optional)
        if let endDate = endDate {
            let endDateString = dateFormatter.string(from: endDate)
            try container.encode(endDateString, forKey: .endDate)
        }
        // If endDate is nil, don't encode it at all
    }
}
