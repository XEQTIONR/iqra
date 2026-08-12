//
//  AppNotificationDelegate.swift
//  iqra
//

import Foundation
import UserNotifications

extension Notification.Name {
    static let foregroundLocalNotification = Notification.Name("foregroundLocalNotification")
}

final class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = AppNotificationDelegate()

    private override init() {
        super.init()
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
}
