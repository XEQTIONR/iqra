//
//  Enrollment.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-18.
//

import Foundation

struct Enrollment: Codable {
    var id: Int
    var startDate: Date
    var endDate: Date
    var price: Double
    var currency: String
    var status: String
    var length: Int
    var schedule: [Day: Int]
    var format: CourseFormat?
    var user: User?
    
    enum CodingKeys: String, CodingKey {
        case id
        case startDate = "start_date"
        case endDate = "end_date"
        case price
        case currency
        case status
        case length
        case schedule
        case format
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

        // Decode start date
        let startDateString = try container.decode(String.self, forKey: .startDate)
        guard let startDate = dateFormatter.date(from: startDateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .startDate,
                in: container,
                debugDescription: "Invalid date format: \(startDateString)"
            )
        }
        self.startDate = startDate

        // Decode end date
        let endDateString = try container.decode(String.self, forKey: .endDate)
        guard let endDate = dateFormatter.date(from: endDateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .endDate,
                in: container,
                debugDescription: "Invalid date format: \(endDateString)"
            )
        }
        self.endDate = endDate
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(price, forKey: .price)
        try container.encode(currency, forKey: .currency)
        try container.encode(status, forKey: .status)
        try container.encode(length, forKey: .length)
        try container.encode(schedule, forKey: .schedule)
        
        let startDateString = dateFormatter.string(from: startDate)
        try container.encode(startDateString, forKey: .startDate)
        
        let endDateString = dateFormatter.string(from: endDate)
        try container.encode(startDateString, forKey: .endDate)
    }
}
