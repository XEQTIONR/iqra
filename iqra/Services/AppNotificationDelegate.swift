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

        // Suppress the system banner; the app shows a toast instead.
        completionHandler([])
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

        if shouldOpenClass,
           response.notification.request.content.categoryIdentifier == Self.classReminderCategoryId {
            NotificationCenter.default.post(name: .openClassSession, object: nil)
        }

        completionHandler()
    }
}
