//
//  InstructorSettings.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-04.
//

import SwiftUI


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
    var languages: Set<String> = []
    var courseCategories = Set<CourseCategory>()
    var titles: Set<Title> = []
    
    var description: String {
        "InstructorSettings(reading: \(reading.rawValue), speaking: \(speaking.rawValue), writing: \(writing.rawValue))"
    }

    init() {}

    enum CodingKeys: String, CodingKey {
        case gender
        case ageGroup
        case reading
        case speaking
        case writing
        case languages
        case courseCategories
        case isMuslim
        case titles
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reading = try container.decodeIfPresent(ReadingLevel.self, forKey: .reading) ?? .no
        speaking = try container.decodeIfPresent(SpeakingLevel.self, forKey: .speaking) ?? .no
        writing = try container.decodeIfPresent(WritingLevel.self, forKey: .writing) ?? .no
        languages = try container.decodeIfPresent(Set<String>.self, forKey: .languages) ?? []
        courseCategories = try container.decodeIfPresent(Set<CourseCategory>.self, forKey: .courseCategories) ?? []
        titles = try container.decodeIfPresent(Set<Title>.self, forKey: .titles) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(reading, forKey: .reading)
        try container.encode(speaking, forKey: .speaking)
        try container.encode(writing, forKey: .writing)
        try container.encode(languages, forKey: .languages)
        try container.encode(courseCategories, forKey: .courseCategories)
        try container.encode(titles, forKey: .titles)
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
