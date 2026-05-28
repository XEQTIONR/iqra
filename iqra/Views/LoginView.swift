//
//  LoginView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-27.
//

import SwiftUI

struct JWTResponse: Codable {
    let user: UserDTO
    let token: String
}


struct LoginView: View {
    
    let LOGIN_ENDPOINT = "http://localhost:8000/api/sanctum/token"
    let JWT_ENDPOINT = "http://localhost:8000/api/jwt"
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    
    private func login() async throws {
        
        guard let url = URL(string: LOGIN_ENDPOINT) else {
            throw URLError(.badURL)
        }
        
        
        let loginData = LoginData(email: email, password: password, device_name: "Default iOS")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(loginData)
        
        
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        print("DATA:")
        print(String(data: data, encoding: .utf8) ?? "No Data")
        print("RESPONSE:")
        print(response)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
            
            if (httpResponse.statusCode == 200) {
                let token = String(data: data, encoding: .utf8)!
                UserDefaults.standard.set(token, forKey: "api_token")
                print(token)
                
                guard let url2 = URL(string: "http://localhost:8000/api/jwt") else {
                    print("XXXXXXXXXXXXXXXXX")
                    throw URLError(.badURL)
                }
                
                var request2 = URLRequest(url: url2)
                request2.httpMethod = "GET"
                request2.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
                request2.setValue("application/json", forHTTPHeaderField: "Accept")
                
                let (data2, code) = try await RequestService.request(
                    url: "http://localhost:8000/api/jwt",
                    headers: [
                        "Authorization": "Bearer \(token)",
                        "Accept": "application/json"
                    ],
                    type: JWTResponse.self
                )
//                let (data2, response2) = try await URLSession.shared.data(for: request2)
                
                print("data2")
                print(data2 ?? "oops")
                print("code")
                print(code ?? "koko")
                
            }
            
        } else {
            // error
        }
    }
    
    
    var body: some View {
        VStack{
            Text("Login!")
            
            TextField("Email", text: $email)
            TextField("Password", text: $password)
                .textContentType(.password)
            
            Button(action: {
                print("Email: \(self.email)")
                print("Password: \(self.password)")
                
                Task {
                    do {
                        let result: () = try await login()
                        print("Result: \(result)")
                    } catch {
                        print("Error: \(error)")
                    }
                }
                
            }) {
                Text("Submit")
            }
        }
        .padding()
        
    }
}

struct LoginData: Codable {
    var email: String
    var password: String
    var device_name: String
}

#Preview {
    LoginView()
}
