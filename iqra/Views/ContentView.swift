//
//  ContentView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI
import SwiftData


enum ContentSection {
    case intro
    case main
}

struct ContentView: View {
    
    @Environment(User.self) var appUser
    @State var currentSection: ContentSection
    @State private var classSession = ClassSession()
    
    init() {
        let introShown = UserDefaults.standard.bool(forKey: "intro_shown")
        if introShown {
            _currentSection = State(initialValue: .main)
        } else {
            UserDefaults.standard.set(true, forKey: "intro_shown")
            _currentSection = State(initialValue: .intro)
        }
    }
    
    var body: some View {
        @Bindable var classSession = classSession

        Group {
            switch currentSection {
            case .intro:
                IntroView($currentSection)
            case .main:
                MainView(currentSection: $currentSection)
                    .environment(classSession)
            }
        }
        .fullScreenCover(item: $classSession.current) { session in
            YView(myClass: session, user: appUser)
        }
        .onAppear {
            openClass(AppNotificationDelegate.shared.consumePendingClass())
        }
        .onReceive(NotificationCenter.default.publisher(for: .openClassSession)) { notification in
            if let pending = AppNotificationDelegate.shared.consumePendingClass() {
                openClass(pending)
                return
            }

            let studentId = intValue(from: notification.userInfo, key: "studentId")!
            let instructorId = intValue(from: notification.userInfo, key: "instructorId")!
            let courseFormatId = intValue(from: notification.userInfo, key: "courseFormatId")!
            
            openClass(MyClass(studentId: studentId, instructorId: instructorId, courseFormatId: courseFormatId))
        }
    }

    private func openClass(_ session: MyClass?) {
        guard let session else { return }
        classSession.current = session
    }

    private func intValue(from userInfo: [AnyHashable: Any]?, key: String) -> Int? {
        guard let value = userInfo?[key] else { return nil }
        if let int = value as? Int { return int }
        if let number = value as? NSNumber { return number.intValue }
        if let string = value as? String { return Int(string) }
        return nil
    }
}

#Preview {
    ContentView()
        .environment(User())
}
