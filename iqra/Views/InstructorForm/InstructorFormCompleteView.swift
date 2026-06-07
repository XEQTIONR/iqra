//
//  InstructorFormCompleteView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-04.
//

import SwiftUI

let CREATE_INSTRUCTOR = "http://localhost:8000/api/instructors"

struct InstructorFormCompleteView: View {
    
    @Environment(User.self) private var appUser
    @Environment(Router.self) private var router
    @Bindable var settings: InstructorSettings

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
            Text("Creating your instructor profile...")
            Text(settings.description)
        }
        .onAppear {
            Task {
                do {
                    let (data, response, ok) = try await RequestService.request(
                        CREATE_INSTRUCTOR,
                        method: "POST",
                        headers: [
                            "Content-Type": "application/json",
                            "Accept": "application/json",
                            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "api_token") ?? "")"
                        ],
                        body: try! JSONEncoder().encode(settings),
                    )
                    
                    if ok {
                        print("OK")
                        print(String(data: data, encoding: .utf8) ?? "NODATA")
                        print(response)
                        
                        let user = try RequestService.apiUnwrapData(type: User.self, from: data)
//                        let user = try JSONDecoder().decode(User.self, from: data)
                        print("userrr")
                        print(user)
                        appUser.update(from: user)
                        router.popToRoot()
                        
                        
                    } else {
                        print("SOMETHING WENT WRONG")
                        print(String(data: data, encoding: .utf8) ?? "NODATA")
                        print(response)
                        /// error handle
                    }
                } catch {
                    
                }
            }
        }
    }
}

#Preview {
    InstructorFormCompleteView(settings: InstructorSettings())
}
