//
//  SettingsView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    
    @Environment(User.self) private var appUser
    @Binding var currentSection: ContentSection
    @State private var loginModalOpen: Bool = false
    @State private var signupModalOpen: Bool = false
    
    
    
    
    init(_ currentSection: Binding<ContentSection>) {
        self._currentSection = currentSection
        
        print("token")
        
        print((UserDefaults.standard.string(forKey: "api_token")) ?? "not-found")
    }

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        if appUser.id != nil {
            Text("Settings")
            Text(appUser.name!)
            Button ("Log") {
                print("appUser:")
                print(appUser)
            }
            Button("Logout", action: {
                Task {
                    // Best-effort: tell the server to revoke the token, but don't
                    // let a failure block the local logout.
                    do {
                        let (data, res, ok) = try await RequestService.request(
                            LOGOUT_ENDPOINT,
                            method: "POST",
                            headers: [
                                "Content-Type": "application/json",
                                "Accept": "application/json",
                                "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "api_token") ?? "")"
                            ],
                        )
                        if !ok {
                            print("Logout request returned a non-success status")
                            print(String(data: data, encoding: .utf8) ?? "NO DATA")
                            print(res)
                        }
                    } catch {
                        print("Logout request failed: \(error)")
                    }

                    // Always clear the local session.
                    UserDefaults.standard.removeObject(forKey: "api_token")
                    appUser.clear()
                }
            }) 
        } else {
            VStack(spacing: 20) {
                Button ("Log") {
                    print("appUser:")
                    print(appUser)
                }
                Button("Login") {
                    loginModalOpen.toggle()
                }
                .sheet(isPresented:$loginModalOpen) {
                    LoginView(completion: {
                        loginModalOpen = false
                    })
                }
                
                Button("Signup") {
                    signupModalOpen.toggle()
                }.sheet(isPresented:$signupModalOpen) {
                    SignupView()
                }
            }
        }
    }
}

#Preview {
    SettingsView(.constant(.main))
        .environment(User())
}
