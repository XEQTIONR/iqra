//
//  AppNotificationDelegate.swift
//  iqra
//

import Foundation
import UserNotifications

extension Notification.Name {
    static let foregroundLocalNotification = Notification.Name("foregroundLocalNotification")
    static let openClassSession = Notification.Name("openClassSession")
}

final class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = AppNotificationDelegate()

    static let classReminderCategoryId = "CLASS_REMINDER"
    static let joinClassActionId = "JOIN_CLASS"

    /// Held when a notification is tapped before UI is ready to navigate.
    private(set) var pendingClass: MyClass?

    private override init() {
        super.init()
    }

    func registerCategories() {
        let joinClass = UNNotificationAction(
            identifier: Self.joinClassActionId,
            title: "Join Class",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: Self.classReminderCategoryId,
            actions: [joinClass],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    @MainActor
    func consumePendingClass() -> MyClass? {
        let pending = pendingClass
        pendingClass = nil
        return pending
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let content = notification.request.content
        let message = content.body.isEmpty ? content.title : content.body

        NotificationCenter.default.post(
            name: .foregroundLocalNotification,
            object: nil,
            userInfo: [
                "message": message,
                "identifier": notification.request.identifier,
                "title": content.title,
                "body": content.body
            ]
        )

        completionHandler([.banner, .sound, .list])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionId = response.actionIdentifier
        let shouldOpenClass =
            actionId == Self.joinClassActionId
            || actionId == UNNotificationDefaultActionIdentifier

        if shouldOpenClass {
            let session = Self.makeClass(from: response.notification.request.content.userInfo)
            Task { @MainActor in
                self.pendingClass = session
                NotificationCenter.default.post(
                    name: .openClassSession,
                    object: nil,
                    userInfo: [
                        "studentId": String(session.studentId),
                        "instructorId": String(session.instructorId),
                        "courseFormatId": String(session.courseFormatId),
                    ]
                )
            }
        }

        completionHandler()
    }

    private static func makeClass(from userInfo: [AnyHashable: Any]) -> MyClass {
        MyClass(
            studentId: intValue(from: userInfo, key: "studentId") ?? 0,
            instructorId: intValue(from: userInfo, key: "instructorId") ?? 0,
            courseFormatId: intValue(from: userInfo, key: "courseFormatId") ?? 0
        )
    }

    private static func intValue(from userInfo: [AnyHashable: Any], key: String) -> Int? {
        guard let value = userInfo[key] else { return nil }
        if let int = value as? Int { return int }
        if let number = value as? NSNumber { return number.intValue }
        if let string = value as? String { return Int(string) }
        return nil
    }
}
