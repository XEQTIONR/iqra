//
//  InstructorFormCompleteView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-04.
//

import SwiftUI

struct InstructorFormCompleteView: View {
    
    @Environment(User.self) private var appUser
    @Environment(Router.self) private var router
    @Environment(\.completion) private var completion
    
    @Bindable var settings: InstructorSettings

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
            Text("Creating your instructor profile...")
        }
        .onAppear {
            guard !ProcessInfo.isRunningInPreview else { return }

            Task {
                do {
                    settings.startAt = Calendar.current.startOfDay(for: Date())
                    
                    let settingsJson = try JSONEncoder().encode(settings)
                    
                    
                    print(RequestService.authJsonHeaders)
                    let (data, response, ok) = try await RequestService.request(
                        INSTRUCTORS_ENDPOINT,
                        method: "POST",
                        headers: RequestService.authJsonHeaders,
                        body: settingsJson,
                    )
                    
                    if ok {
                        let user = try RequestService.apiUnwrapData(type: User.self, from: data)
                        appUser.update(from: user)
                        router.popToRoot()
                        completion!()
                    } else {
                        print("SOMETHING WENT WRONG")
                        print(String(data: data, encoding: .utf8) ?? "NODATA")
                        print(response)
                        /// error handle
                    }
                } catch {
                    /// more error handling
                }
            }
        }
    }
}

#Preview {
    InstructorFormCompleteView(settings: InstructorSettings())
        .environment(User())
        .environment(Router())
        .environment(\.completion, nil)
}
