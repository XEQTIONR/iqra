//
//  Router.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-06.
//

import SwiftUI

let COURSES_ENDPOINT = "http://localhost:8000/api/courses"
let FEED_ENDPOINT = "http://localhost:8000/api/feed"
let INSTRUCTORS_ENDPOINT = "http://localhost:8000/api/instructors"
let JWT_ENDPOINT = "http://localhost:8000/api/jwt"
let LOGIN_ENDPOINT = "http://localhost:8000/api/sanctum/token"
let LOGOUT_ENDPOINT = "http://localhost:8000/api/logout"
let ME_ENDPOINT = "http://localhost:8000/api/user"
let SIGNUP_ENDPOINT = "http://localhost:8000/api/register"
let UPLOADS_ENDPOINT = "http://localhost:8000/api/uploads"

enum Route: Hashable {
    case course(Course)
    case instructorArabicForm
    case instructorLanguageForm(InstructorSettings)
    case instructorCourseTypeForm(InstructorSettings)
    case instructorQualificationForm(InstructorSettings)
    case instructorAvailibilityForm(InstructorSettings)
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
            InstructorArabicFormView(completion: nil)
        case .instructorLanguageForm(let settings):
            InstructorLanguageFormView(settings: settings)
        case .instructorCourseTypeForm(let settings):
            InstructorCourseTypeFormView(settings: settings)
        case .instructorQualificationForm(let settings):
            InstructorQualificationFormView(settings: settings)
        case .instructorAvailibilityForm(let settings):
            InstructorAvailabilityFormView(settings: settings)
        case .instructorFormComplete(let settings):
            InstructorFormCompleteView(settings: settings)
        case .instructorUnqualified:
            InstructorUnqalifiedView()
        case .signup:
            SignupView()
        }
    }
}
