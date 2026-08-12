//
//  iqraApp.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct iqraApp: App {
    
    @State private var user: User = {
        let initialUser = User()
        if let cached = User.loadCached() {
            initialUser.update(from: cached)
        }
        return initialUser
    }()

    init() {
        UNUserNotificationCenter.current().delegate = AppNotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(user)
                .task {
                    await fetchUserData()
                }
        }
    }
    
    private func fetchUserData() async {
        guard UserDefaults.standard.string(forKey: "api_token") != nil else { return }
        
        do {
            let (data, _, ok) = try await RequestService.request(
                ME_ENDPOINT,
                method: "GET",
                headers: RequestService.authJsonHeaders
            )
            
            if ok {
                let fetchedUser = try RequestService.apiUnwrapData(type: User.self, from: data)
                self.user.update(from: fetchedUser)
            }
        } catch {
            print("Failed to update user profile: \(error)")
        }
    }
}
