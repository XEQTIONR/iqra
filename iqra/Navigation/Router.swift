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
    case instructorLanguageForm(InstructorSettings)
    case instructorCourseTypeForm(InstructorSettings)
    case instructorQualificationForm(InstructorSettings)
    case instructorFormComplete(InstructorSettings)
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
        case .instructorLanguageForm(let settings):
            InstructorLanguageFormView(settings: settings)
        case .instructorCourseTypeForm(let settings):
            InstructorCourseTypeFormView(settings: settings)
        case .instructorQualificationForm(let settings):
            InstructorQualificationFormView(settings: settings)
        case .instructorFormComplete(let settings):
            InstructorFormCompleteView(settings: settings)
        case .instructorUnqualified:
            InstructorUnqalifiedView()
        case .signup:
            SignupView()
        }
    }
}
