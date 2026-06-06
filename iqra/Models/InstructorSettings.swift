//
//  InstructorSettings.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-04.
//

import SwiftUI

enum Gender: String, CaseIterable, Codable {
    case male
    case female
}

enum ReadingLevel: String, CaseIterable {
    case no
    case withHarakat
    case withoutHarakat
    
    var label: String {
        switch self {
        case .no: return "I cannot read Arabic"
        case .withHarakat: return "I can read Arabic with harakat/tashkeel"
        case .withoutHarakat: return "I can read Arabic with or without harakat/tashkeel"
        }
    }
}

enum SpeakingLevel: String, CaseIterable {
    case no
    case wordsOnly
    case MSA
    case multiple
    case native
    
    var label: String {
        switch self {
        case .no: return "I cannot speak Arabic"
        case .wordsOnly: return "I can speak Arabic words but I do not understand them"
        case .MSA: return "I can speak and I understand Modern Standard Arabic (MSA) / Fusha"
        case .multiple: return "I can speak and I understand multiple Arabic dialects"
        case .native: return "I am Arab, I speak and understand most Arabic dialects"
        }
    }
}

enum WritingLevel: String, CaseIterable {
    case no
    case yes
    
    var label: String {
        switch self {
        case .no: return "I cannot write in Arabic"
        case .yes: return "I can write in Arabic"
        }
    }
}



enum AgeGroup: String, CaseIterable {
    case aLessThan19
    case a19To24
    case a25To34
    case a35To44
    case a45To54
    case a55plus
}

enum CourseCategory: String, CaseIterable {
    case islamic
    case arabic
}

enum Title: String, CaseIterable {
    case hafiz
    case hujjat
    case qari
    case imaam
    case alim
    case mufti
    case ayatollah
}

@Observable
class InstructorSettings {
    var gender: Gender? // scrap
    var ageGroup: String? // scrap
    var reading: ReadingLevel = .no
    var speaking: SpeakingLevel = .no
    var writing: WritingLevel = .no
    var languages: Set<String> = []
    var courseCategories = Set<CourseCategory>()
    var isMuslim: Bool?
    var titles: Set<Title> = []
    
    var description: String {
        "InstructorSettings(reading: \(reading.label), speaking: \(speaking.label), writing: \(writing.label), isMuslim: \(String(describing: isMuslim))"
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
