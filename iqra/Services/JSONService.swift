//
//  JSONService.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-24.
//

import Foundation

let COURSES_ENDPOINT = "http://localhost:8000/api/courses"
let LOGIN_ENDPOINT = "http://localhost:8000/api/sanctum/token"
let LOGOUT_ENDPOINT = "http://localhost:8000/api/logout"
let ME_ENDPOINT = "http://localhost:8000/api/user"
let JWT_ENDPOINT = "http://localhost:8000/api/jwt"

class JSONService {
    static public func loadLocalJSON<T: Codable & Identifiable>(fileName: String) -> [T]? {
        // 1. Find the file in the bundle
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("File not found")
            return nil
        }

        do {
            // 2. Load the file content into Data
            let data = try Data(contentsOf: url)
            
            // 3. Decode the data
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
}
