//
//  Router.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-06.
//

import SwiftUI

let BASE = "https://gsd8s8dacnl1.shares.zrok.io"
let COURSES_ENDPOINT = "\(BASE)/api/courses"
let ENROLLMENTS_ENDPOINT = "\(BASE)/api/enrollments"
let FEED_ENDPOINT = "\(BASE)/api/feed"
let INSTRUCTORS_ENDPOINT = "\(BASE)/api/instructors"
let JWT_ENDPOINT = "\(BASE)/api/jwt"
let LOGIN_ENDPOINT = "\(BASE)/api/sanctum/token"
let LOGOUT_ENDPOINT = "\(BASE)/api/logout"
let ME_ENDPOINT = "\(BASE)/api/user"
let SIGNUP_ENDPOINT = "\(BASE)/api/register"
let UPLOADS_ENDPOINT = "\(BASE)/api/uploads"

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
    var showToast = false
    var toastMessage = ""

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

    func presentToast(_ message: String) {
        toastMessage = message
        withAnimation {
            showToast = true
        }
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
