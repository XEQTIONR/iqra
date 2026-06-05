//
//  SignupView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-04.
//

import SwiftUI

let SIGNUP_ENDPOINT = "http://localhost:8000/api/register"

struct SignupData: Codable {
    var name: String
    var email: String
    var password: String
    var birthday: String
    var gender: String
    var device_name: String
}

struct SignupResponse: Codable {
    var user: User
    var token: String
}

struct SignupView: View {
    
    @Environment(User.self) private var appUser
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var birthday = Date()
    @State private var gender: Gender? = .male
    
    
    
    private func signUp() async throws {
        let signUpData = SignupData (
            name: name,
            email: email,
            password: password,
            birthday: String("\(birthday)".split(separator: " ")[0]),
            gender: gender?.rawValue ?? "male",
            device_name: UIDevice.current.name
        )
        
        let (data, response, ok) = try await RequestService.request(
            SIGNUP_ENDPOINT,
            method: "POST",
            headers: RequestService.jsonHeaders,
            body: try JSONEncoder().encode(signUpData)
        )
        
        print(String(data: data, encoding: .utf8) ?? "No Data")
        
        if ok {
            
            let res = try JSONDecoder().decode(SignupResponse.self, from: data)
            print(res.token)
            print(res.user)
            appUser.update(from: res.user)
            
        } else {
            print("Oops")
            print(response)
        }
        
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Sign Up")
            
            VStack(alignment: .leading, spacing: 10){
                Label("Full Name", image: "")
                    .labelStyle(.titleOnly)
                TextField("John Doe", text: $name)
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                    }
            }.frame(maxWidth: .infinity)
            
            
            VStack(alignment: .leading, spacing: 10){
                Label("Email", image: "")
                    .labelStyle(.titleOnly)
                TextField("", text: $email, prompt: Text(verbatim: "example@email.com"))
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                    }
            }.frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 10){
                Label("Password", image: "")
                    .labelStyle(.titleOnly)
                SecureField("Your password", text: $password)
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                    }
            }.frame(maxWidth: .infinity)
            
            DatePicker(
                "Birthday",
                selection: $birthday,
                displayedComponents: [.date]
            ).environment(\.timeZone, TimeZone(secondsFromGMT: 0)!)
            
            HStack(spacing: 30) {
                Text("Gender")
                Picker("Gender", selection: $gender) {
                    Text("Male").tag(Gender.male)
                    Text("Female").tag(Gender.female)
                }
                .pickerStyle(.segmented)
            }
            
            Button(action: {
                Task {
                    try await signUp()
                }
            }) {
                Text("Sign up")
            }
        
        }.padding()
    }
}

#Preview {
    SignupView()
        .environment(User())
}
