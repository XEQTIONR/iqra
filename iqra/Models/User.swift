//
//  User.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-27.
//

import Foundation
import SwiftData

struct UserDTO: Codable {
    let id: Int
    let name: String
    let email: String
}


@Model
class User: Identifiable, Codable {
    @Attribute(.unique) var id: Int
    var name: String
    var email: String
    
    init(id: Int, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    convenience init(dto: UserDTO) {
        self.init(id: dto.id, name: dto.name, email: dto.email)
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
    }
}

extension User {
    var dto: UserDTO {
        UserDTO(id: id, name: name, email: email)
    }
}
