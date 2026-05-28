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
}


@Model
class User: Identifiable {
    var id: Int
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    convenience init(dto: UserDTO) {
        self.init(id: dto.id, name: dto.name)
    }
}
