//
//  SettingsView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    
    @Binding var currentSection: ContentSection
    @State private var modalOpen: Bool = false
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var users: [User]
    
    
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
        if users.count > 0 {
            Text("Settings")
            Text(users[0].name)
            Button("Logout", action: {
                Task {
                    do {
                        print("API TOKEN")
                        print(UserDefaults.standard.string(forKey: "api_token") ?? "NO TOKEN")
                        let (_, res) = try await RequestService.request(
                            LOGOUT_ENDPOINT,
                            method: "POST",
                            headers: [
                                "Content-Type": "application/json",
                                "Accept": "application/json",
                                "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "api_token") ?? "")"
                            ],
                        )
                        
                        let response = res as! HTTPURLResponse
                        
                        switch response.statusCode {
                        case 200, 204:
                            
                            UserDefaults.standard.removeObject(forKey: "api_token")
                            let allUsers = try modelContext.fetch(FetchDescriptor<User>())
                            for user in allUsers {
                                modelContext.delete(user)
                            }
                            try modelContext.save()
                        default:
                            print("error")
                            print (response)
                        }
//                        let (data, _) = try await RequestService.request(
//                            COURSES_ENDPOINT,
//                            headers: [
//                                "Content-Type": "application/json",
//                                "Accept": "application/json",
//                                "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "api_token") ?? "")"
//                            ],
//                        )
//                        
//                        print(String(data: data, encoding: .utf8)!)
//                        print(response)
                    } catch {
                        
                    }
                }
                
            }) 
        } else {
            Button("Login") {
                modalOpen.toggle()
            }.sheet(isPresented:$modalOpen) {
                
                
                LoginView(completion: {() -> Void in
                    modalOpen = false
                })
            }
        }
    }
}

#Preview {
    SettingsView(.constant(.main))
}
