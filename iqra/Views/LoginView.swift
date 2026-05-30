//
//  LoginView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-27.
//

import SwiftUI

let COURSES_ENDPOINT = "http://localhost:8000/api/courses"
let LOGIN_ENDPOINT = "http://localhost:8000/api/sanctum/token"
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
        
        var (data, response) = try await RequestService.request(
            LOGIN_ENDPOINT,
            method: "POST",
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ],
            body: try JSONEncoder().encode(loginData)
        )
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200:
                let token = String(data: data, encoding: .utf8)!
                UserDefaults.standard.set(token, forKey: "api_token")
                
                
                (data, response) = try await RequestService.request(
                    ME_ENDPOINT,
                    headers: [
                        "Content-Type": "application/json",
                        "Accept": "application/json",
                        "Authorization": "Bearer \(token)"
                    ],
                )
                
                if let httpRes = response as? HTTPURLResponse {
                    switch httpRes.statusCode {
                    case 200:
                        let user = try JSONDecoder().decode(User.self, from: data)
                        
                        
                        (data, response) = try await RequestService.request(
                            COURSES_ENDPOINT,
                            headers: [
                                "Content-Type": "application/json",
                                "Accept": "application/json",
                                "Authorization": "Bearer \(token)"
                            ],
                        )
                        
                        print("data")
                        print(data)
                        
                        
                        
                        modelContext.insert(user)
                        
                    default:
                        print("ME NOT OK")
                    }
                }
                
                print(String(data:data, encoding: .utf8) ?? "OOPS")
                print(response)
                
                
                completion?()
                break
            case 422:
                let errs = try JSONDecoder().decode(ErrorResponse.self, from: data)
                print(errs)
                /// show error messages
                break
            default:
                break
                /// do nothing
            }
//            if (httpResponse.statusCode == 200) {
//                let token = String(data: data, encoding: .utf8)!
//                UserDefaults.standard.set(token, forKey: "api_token")
//                print(token)
//                
//                guard let url2 = URL(string: "http://localhost:8000/api/jwt") else {
//                    print("XXXXXXXXXXXXXXXXX")
//                    throw URLError(.badURL)
//                }
//                
//                var request2 = URLRequest(url: url2)
//                request2.httpMethod = "GET"
//                request2.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
//                request2.setValue("application/json", forHTTPHeaderField: "Accept")
//                
//                let (data2, code) = try await RequestService.request(
//                    url: "http://localhost:8000/api/jwt",
//                    headers: [
//                        "Authorization": "Bearer \(token)",
//                        "Accept": "application/json"
//                    ],
//                    type: JWTResponse.self
//                )
//                let (data2, response2) = try await URLSession.shared.data(for: request2)
//                
//                print("data2")
//                print(data2 ?? "oops")
//                print("code")
//                print(code ?? "koko")
//                
//            }
        } else {
            /// error
        }
    }
    
    var body: some View {
        VStack(spacing: 25){
            Text("Login!")
            TextField("Email", text: $email)
            TextField("Password", text: $password)
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
