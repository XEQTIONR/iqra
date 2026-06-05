//
//  LoginView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-27.
//

import SwiftUI

let COURSES_ENDPOINT = "http://localhost:8000/api/courses"
let LOGIN_ENDPOINT = "http://localhost:8000/api/sanctum/token"
let LOGOUT_ENDPOINT = "http://localhost:8000/api/logout"
let ME_ENDPOINT = "http://localhost:8000/api/user"
let JWT_ENDPOINT = "http://localhost:8000/api/jwt"

struct JWTResponse: Codable {
    let user: UserDTO
    let token: String
}

struct ErrorResponse: Decodable {
    let message: String
    let errors: [String: [String]]
}

struct LoginData: Codable {
    var email: String
    var password: String
    var device_name: String
}


struct LoginView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var email: String = ""
    @State private var password: String = ""
    let completion: (() -> Void)?
    
    private func login() async throws {

        let loginData = LoginData(email: email, password: password, device_name: "Default iOS")
        
        var (data, response, ok) = try await RequestService.request(
            LOGIN_ENDPOINT,
            method: "POST",
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ],
            body: try JSONEncoder().encode(loginData)
        )
        
        if ok {
            let token = String(data: data, encoding: .utf8)!
            UserDefaults.standard.set(token, forKey: "api_token")
            
            
            (data, response, ok) = try await RequestService.request(
                ME_ENDPOINT,
                headers: [
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                    "Authorization": "Bearer \(token)"
                ],
            )
            
            if ok {
                let user = try JSONDecoder().decode(User.self, from: data)
                modelContext.insert(user)
            } else {
                /// error handle here
                print("ME NOT OK")
            }
            
            print(String(data:data, encoding: .utf8) ?? "OOPS")
            print(response)
            
            completion?()
            
        } else if let httpResponse = response as? HTTPURLResponse {
            
            if httpResponse.statusCode == 422 {
                let errs = try JSONDecoder().decode(ErrorResponse.self, from: data)
                print(errs)
                /// show error messages
            } else {
                /// general error handling
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 25){
            Text("Login!")
            TextField("Email", text: $email)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .textContentType(.emailAddress)
            SecureField("Password", text: $password)
                .textContentType(.password)
            
            Button("Submit", action: {
                Task {
                    do {
                        let result: () = try await login()
                        print("Result: \(result)")
                    } catch {
                        print("Error: \(error)")
                    }
                }
            })
        }
        .padding()
    }
}

#Preview {
    LoginView(completion: nil)
}
