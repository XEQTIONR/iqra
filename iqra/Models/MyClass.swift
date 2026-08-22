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
    var id: String { "\(studentId)-\(instructorId)" }
    var studentId: Int
    var instructorId: Int
    
    init(studentId: Int, instructorId: Int) {
        self.studentId = studentId
        self.instructorId = instructorId
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
            instructorId: User.instructorPreview.id!
        )
    }
}
#endif
