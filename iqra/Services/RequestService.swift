//
//  RequestService.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-28.
//

import Foundation


enum RequestError: Error {
    case encodingFailed
//    case unauthorized
//    case serverError(code: Int) // Associated values provide extra context
}

class RequestService {
    
    public static func request<T: Codable>(
        url: String,
        method: String? = "GET",
        headers: [String: String]? = [:],
        body: Data? = nil,
        type: T.Type
        
    ) async throws -> (T?, Int?) {
        var isJSON = false
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        
        if let h = headers {
            for (header, value) in h {
                request.setValue(value, forHTTPHeaderField: header)
                
                if header == "Accept" && value == "application/json" {
                    isJSON = true
                }
                
                if body != nil {
                    if header == "Content-Type" && value == "application/json" {
                        do {
                            request.httpBody = try JSONEncoder().encode(body)
                        } catch {
                            throw RequestError.encodingFailed
                        }
                        
                        
                    } else {
                        request.httpBody = body
                    }
                }
                
            }
        }
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        
        if  isJSON {
            do {
                return (try JSONDecoder().decode(T.self, from: data), httpResponse?.statusCode ?? 0)
            } catch {
                throw RequestError.encodingFailed
            }
        }
        return (data as? T, httpResponse?.statusCode ?? 0)
    }
}
