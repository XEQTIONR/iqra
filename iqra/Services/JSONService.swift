//
//  JSONService.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-24.
//

import Foundation

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
            let decoder = JSONDecoder()
            let users = try decoder.decode([T].self, from: data)
            return users
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
}
