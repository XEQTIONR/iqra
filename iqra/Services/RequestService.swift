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
    
    public static let jsonHeaders : [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]
    
    public static func request(
        _ url: String,
        method: String? = "GET",
        headers: [String: String]? = [:],
        body: Data? = nil,
        
    ) async throws -> (Data, URLResponse, Bool) {
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        
        if let h = headers {
            for (header, value) in h {
                request.setValue(value, forHTTPHeaderField: header)
            }
        }
        
        if let b = body {
            request.httpBody = b
        }
        
        
        let (data, response)  = try await URLSession.shared.data(for: request)
        
        let httpResponse = response as! HTTPURLResponse
        let isSuccess = httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
        
        return (data, response, isSuccess)
        
    }
    
    private struct DataWrapper<T: Decodable>: Decodable {
        let data: T
    }
    
    public static func apiUnwrapData<T: Decodable>(type: T.Type, from data: Data) throws -> T {
        let wrapper = try JSONDecoder().decode(DataWrapper<T>.self, from: data)
        return wrapper.data
    }
        
}
