//
//  InstructorSettings.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-04.
//

import Foundation


enum AgeGroup: String, CaseIterable, Codable {
    case kids
    case teens
    case youngAdults
    case seniors
}

enum Gender: String, CaseIterable, Codable {
    case male
    case female
}

enum ReadingLevel: String, CaseIterable, Codable {
    case no
    case withHarakat
    case withoutHarakat
}

enum SpeakingLevel: String, CaseIterable, Codable {
    case no
    case wordsOnly
    case MSA
    case multiple
    case native
}

enum WritingLevel: String, CaseIterable, Codable {
    case no
    case yes
}

enum CourseCategory: String, CaseIterable, Codable {
    case reading
    case qScience
    case hScience
    case calligraphy
}

enum Title: String, CaseIterable, Codable {
    case hafiz
    case hujjat
    case qari
    case imaam
    case alim
    case mufti
    case ayatollah
}

@Observable
class InstructorSettings: Codable {
    var reading: ReadingLevel = .no
    var speaking: SpeakingLevel = .no
    var writing: WritingLevel = .no
    var courseCategories = Set<CourseCategory>()
    var languages: Set<String> = []
    var titles: Set<Title> = []
    var availability: [Day: Set<Int>] = [:]
    var startAt: Date = Calendar.current.startOfDay(for: Date())
    var endAt: Date?
    var timezone: TimeZone = TimeZone.current
    
    var description: String {
        "InstructorSettings(reading: \(reading.rawValue), speaking: \(speaking.rawValue), writing: \(writing.rawValue))"
    }

    init() {}

    enum CodingKeys: String, CodingKey {
        case gender
        case reading
        case speaking
        case writing
        case languages
        case courseCategories = "course_categories"
        case titles
        case availability
        case timezone
        case startAt = "start_at"
        case endAt = "end_at"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reading = try container.decodeIfPresent(ReadingLevel.self, forKey: .reading) ?? .no
        speaking = try container.decodeIfPresent(SpeakingLevel.self, forKey: .speaking) ?? .no
        writing = try container.decodeIfPresent(WritingLevel.self, forKey: .writing) ?? .no
        languages = try container.decodeIfPresent(Set<String>.self, forKey: .languages) ?? []
        courseCategories = try container.decodeIfPresent(Set<CourseCategory>.self, forKey: .courseCategories) ?? []
        titles = try container.decodeIfPresent(Set<Title>.self, forKey: .titles) ?? []
        startAt = try container.decode(Date.self, forKey: .startAt)
        endAt = try container.decodeIfPresent(Date.self, forKey: .endAt)
        timezone = try TimeZone.init(from: (container.decodeIfPresent(String.self, forKey: .timezone)
                                            ?? TimeZone.current.identifier) as! Decoder)
        
        let rawAvailability = try container.decodeIfPresent([String: [Int]].self, forKey: .availability) ?? [:]
        availability = Dictionary(uniqueKeysWithValues: rawAvailability.compactMap { key, value in
            Day(rawValue: key).map { ($0, Set(value)) }
        })
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(reading, forKey: .reading)
        try container.encode(speaking, forKey: .speaking)
        try container.encode(writing, forKey: .writing)
        try container.encode(languages, forKey: .languages)
        try container.encode(courseCategories, forKey: .courseCategories)
        try container.encode(titles, forKey: .titles)
        try container.encode(timezone.identifier, forKey: .timezone)
        try container.encode(startAt.ISO8601Format(), forKey: .startAt)
        try container.encode(endAt?.ISO8601Format() ?? nil, forKey: .endAt)

        let availabilityObject = Dictionary(uniqueKeysWithValues: availability.map { ($0.key.rawValue, Array($0.value)) })
        try container.encode(availabilityObject, forKey: .availability)
    }
}

extension InstructorSettings: Hashable {
    static func == (lhs: InstructorSettings, rhs: InstructorSettings) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
