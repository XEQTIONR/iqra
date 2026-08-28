//
//  MyClass.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-08-12.
//

import Foundation
import Observation

@Observable
class MyClass: Identifiable, Equatable {
    var id: String { "\(courseFormatId)-\(instructorId)-\(studentId)" }
    var studentId: Int
    var instructorId: Int
    var courseFormatId: Int
    
    init(studentId: Int, instructorId: Int, courseFormatId: Int) {
        self.studentId = studentId
        self.instructorId = instructorId
        self.courseFormatId = courseFormatId
    }
    
    static func == (lhs: MyClass, rhs: MyClass) -> Bool {
        return lhs.id == rhs.id
    }
}

@Observable
final class ClassSession {
    var current: MyClass?
}

#if DEBUG
extension MyClass {
    static var preview: MyClass {
        return MyClass(
            studentId: User.studentPreview.id!,
            instructorId: User.instructorPreview.id!,
            courseFormatId: CourseFormat.preview.id!
        )
    }
}
#endif
