//
//  Course.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-24.
//

import Foundation

enum LengthType: String, CaseIterable, Codable, Hashable {
    case fixed, ongoing
}

enum Difficulty: String, CaseIterable, Codable, Hashable {
    case beginner
    case intermediate
    case advanced
}

struct Course: Codable, Hashable {
    let id: Int
    let title: String
    let image: String?
    let description: String
    let difficulty: Difficulty
    let category: CourseCategory
    let length_type: LengthType
    let age_groups: [AgeGroup]
}
