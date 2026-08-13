//
//  MyClass.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-08-12.
//

import Foundation

struct MyClass: Identifiable, Equatable {
    var id: String { "\(studentId)-\(instructorId)" }
    var studentId: Int
    var instructorId: Int
}
