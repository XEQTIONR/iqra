//
//  RequestService.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-28.
//

import Foundation
import UIKit
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
    
    public func updateJSONToken() async throws {
        let token = UserDefaults.standard.value(forKey: "api_token") as! String
        var headers = ["Authorization": "Bearer \(token)"]
        headers.merge(RequestService.jsonHeaders) { (current, new) in new }

        let (data, _, ok) = try await RequestService.request(
            "http://localhost:8000/api/jwt",
            headers: headers,
        )

        if ok {
            UserDefaults.standard.set(String(data: data, encoding: .utf8), forKey: "jwt")
        } else {
            /// do error handling here
        }
    }
    
    private struct DataWrapper<T: Decodable>: Decodable {
        let data: T
    }
    
    public static func apiUnwrapData<T: Decodable>(type: T.Type, from data: Data) throws -> T {
        let wrapper = try JSONDecoder().decode(DataWrapper<T>.self, from: data)
        return wrapper.data
    }
    
    public static func apiUnwrapCollection<T: Decodable>(
        type: T.Type,
        from data: Data
    ) throws -> [T] {
        let wrapper = try JSONDecoder().decode(DataWrapper<[T]>.self, from: data)
        return wrapper.data
    }
    
    public static func uploadImage(
        _ image: UIImage,
        serverURL: URL,
        fieldName: String
    ) async throws -> (Data, URLResponse, Bool) {

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw RequestError.encodingFailed
        }
        
        return try await uploadMultipartFile(
            serverURL,
            data: imageData,
            fieldName: fieldName,
            fileName: "image.jpg",
            mimeType: "image/jpeg"
        )

    }
    
    public static func uploadFileUrl(
        _ fileURL: URL,
        serverURL: URL,
        fieldName: String
    ) async throws -> (Data, URLResponse, Bool) {

        let fileName = fileURL.lastPathComponent
        let mimeType = getMimeType(from: fileURL)
        let fileData = try Data(contentsOf: fileURL)
        
        return try await uploadMultipartFile(
            serverURL,
            data: fileData,
            fieldName: fieldName,
            fileName: fileName,
            mimeType: mimeType
        )

    }
    
    public static func uploadMultipartFile(
        _ serverURL: URL,
        data: Data,
        fieldName: String,
        fileName: String,
        mimeType: String,
    
    ) async throws -> (Data, URLResponse, Bool) {

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: serverURL)
        
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "api_token") ?? "")", forHTTPHeaderField: "Authorization")
        
        var body = Data()
        
        // Append file field header
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        
        // Append raw file data
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close the multipart request boundary closing tag
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Execute the upload task
        let (data, response) = try await URLSession.shared.upload(for: request, from: body)
        
        let httpResponse = response as! HTTPURLResponse
        let isSuccess = httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
        
        return (data, response, isSuccess)
    }
        
}
