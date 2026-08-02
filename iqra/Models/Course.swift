//
//  Course.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-24.
//

import Foundation

enum BillingUnit: String, CaseIterable, Codable {
    case hour
    case lesson
    case week
    case month
}

enum Difficulty: String, CaseIterable, Codable, Hashable {
    case beginner
    case intermediate
    case advanced
}

enum LengthType: String, CaseIterable, Codable, Hashable {
    case fixed, ongoing
}

struct CourseFormat: Hashable, Codable {
    var id: Int? = nil
    var title: String
    var description: String
    var unit: BillingUnit
    var lessonLength: Int
    var lessonsPerWeek: Int
    var totalLessons: Int
    var price: Double
    var billingCycles: Int? = nil
    var course: Course? = nil
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case unit
        case lessonLength = "lesson_length"
        case lessonsPerWeek = "lessons_per_week"
        case totalLessons = "total_lessons"
        case price
        case billingCycles = "billing_cycles"
        case course
    }
}

struct Course: Codable, Hashable {
    var id: Int?
    var title: String
    var description: String
    var image: String
    var video: String
    var difficulty: Difficulty
    var category: CourseCategory
    var lengthType: LengthType
    var ageGroups: [AgeGroup]
    var isPublished: Bool = false
    var formats: [CourseFormat]? = []
    var totalLessons: Int?
    var instructor: User? = nil
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case image
        case video
        case difficulty
        case category
        case lengthType = "length_type"
        case ageGroups = "age_groups"
        case isPublished = "is_published"
        case formats
        case totalLessons = "total_lessons"
        case instructor
    }
}


