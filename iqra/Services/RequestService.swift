//
//  RequestService.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-28.
//

import Foundation
import UniformTypeIdentifiers


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
    
    public static let authJsonHeaders : [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "api_token") ?? "")"
    ]
    
    public static func getMimeType(from url: URL) -> String {
        let pathExtension = url.pathExtension
        
        // Look up the UTType associated with the extension
        if let utType = UTType(filenameExtension: pathExtension) {
            // Return the preferred MIME type string
            return utType.preferredMIMEType ?? "application/octet-stream"
        }
        
        return "application/octet-stream"
    }
    
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
    
    public static func uploadMultipartFile(fileURL: URL, fieldName: String, to serverURL: URL) async throws -> (Data, URLResponse, Bool) {
        let pathExt = fileURL.pathExtension
        
        // 1. Create a unique boundary string
        let boundary = "Boundary-\(UUID().uuidString)"
        
        // 2. Setup the request
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "api_token") ?? "")", forHTTPHeaderField: "Authorization")
        
        
        // 3. Prepare file metadata
        let fileName = fileURL.lastPathComponent
        let mimeType = getMimeType(from: fileURL) // Adjust based on your file type
        
            // 4. Fetch the raw file bytes
            let fileData = try Data(contentsOf: fileURL)
            
            // 5. Construct the HTTP request body format
            var body = Data()
            
            // Append file field header
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            
            // Append raw file data
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
            
            // Close the multipart request boundary closing tag
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            // 6. Execute the upload task
            let (data, response) = try await URLSession.shared.upload(for: request, from: body)
            
            let httpResponse = response as! HTTPURLResponse
            let isSuccess = httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
            
            return (data, response, isSuccess)
    }
        
}
