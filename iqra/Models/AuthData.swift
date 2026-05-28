//
//  AuthData.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-27.
//

import Foundation
import SwiftData

class AuthData: Codable, Identifiable {
    var id: String
    var apiToken: String
    var jwt: String?
}
