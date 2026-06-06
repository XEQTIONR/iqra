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
    
    @Environment(User.self) private var appUser
    @State private var email: String = ""
    @State private var password: String = ""
    let completion: (() -> Void)?
    
    private func login() async throws {

        let loginData = LoginData(email: email, password: password, device_name: UIDevice.current.name)
        
        let (data, response, ok) = try await RequestService.request(
            LOGIN_ENDPOINT,
            method: "POST",
            headers: RequestService.jsonHeaders,
            body: try JSONEncoder().encode(loginData)
        )
        
        if ok {

            let res = try JSONDecoder().decode(SignupResponse.self, from: data)
            UserDefaults.standard.set(res.token, forKey: "api_token")

            
            appUser.update(from: res.user)
            
            
            try await Task.sleep(nanoseconds: 250_000_000)
            completion!()
            
            

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
        NavigationStack {
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
                
                NavigationLink("Sign Up", destination: SignupView())
            }
            .padding()
        }
    }
}

#Preview {
    LoginView(completion: nil)
        .environment(User())
}
