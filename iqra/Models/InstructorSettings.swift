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
}

enum SpeakingLevel: String, CaseIterable {
    case no
    case wordsOnly
    case MSA
    case multiple
    case native
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
    var reading: ReadingLevel?
    var speaking: SpeakingLevel?
    var writing: Bool?
    var languages: Set<String> = []
    var courseCategories = Set<CourseCategory>()
    var isMuslim: Bool?
    var titles: Set<Title> = []
}
