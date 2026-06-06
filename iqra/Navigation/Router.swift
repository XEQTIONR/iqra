//
//  Router.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-06.
//

import SwiftUI

enum Route: Hashable {
    case course(Course)
    case instructorArabicForm
    case instructorLanguageForm
    case instructorCourseTypeForm
    case instructorMuslimForm
    case instructorQualificationForm
    case instructorFormComplete
    case instructorUnqualified
    case signup
}

@Observable
final class Router {
    var path = NavigationPath()

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}

extension Route {
    @MainActor
    @ViewBuilder
    var destination: some View {
        switch self {
        case .course(let course):
            CourseView(course: course)
        case .instructorArabicForm:
            InstructorArabicFormView()
        case .instructorLanguageForm:
            InstructorLanguageFormView()
        case .instructorCourseTypeForm:
            InstructorCourseTypeFormView()
        case .instructorMuslimForm:
            InstructorMuslimFormView()
        case .instructorQualificationForm:
            InstructorQualificationFormView()
        case .instructorFormComplete:
            InstructorFormCompleteView()
        case .instructorUnqualified:
            InstructorUnqalifiedView()
        case .signup:
            SignupView()
        }
    }
}
