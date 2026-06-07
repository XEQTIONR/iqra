//
//  User.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-27.
//

import Foundation
import SwiftData


@Observable
class User: Codable, CustomStringConvertible {
    var id: Int?
    var name: String?
    var email: String?
    var gender: String?
    var birthday: String?
    var isInstructor: Bool?

    init() {}

    // Explicit Codable is required because the `@Observable` macro rewrites
    // stored properties into underscore-backed storage (`_name`, `_id`, ...),
    // which breaks synthesized Codable (it would look for `_name`/`_email`
    // keys in the JSON and silently decode everything as nil).
    enum CodingKeys: String, CodingKey {
        case id, name, email, gender, birthday, isInstructor
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        birthday = try container.decodeIfPresent(String.self, forKey: .birthday)
        isInstructor = try container.decodeIfPresent(Bool.self, forKey: .isInstructor)
        
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encodeIfPresent(birthday, forKey: .birthday)
        try container.encodeIfPresent(isInstructor, forKey: .isInstructor)
    }

    /// Copies fields from another user into this shared instance so that
    /// `@Environment(User.self)` observers update without reassigning.
    func update(from other: User) {
        id = other.id
        name = other.name
        email = other.email
        gender = other.gender
        birthday = other.birthday
        isInstructor = other.isInstructor
        save()
    }

    /// Resets the user to a logged-out state.
    func clear() {
        id = nil
        name = nil
        email = nil
        gender = nil
        birthday = nil
        isInstructor = nil
        UserDefaults.standard.removeObject(forKey: User.storageKey)
    }

    // MARK: - Persistence

    private static let storageKey = "cached_user"

    /// Writes the current user to `UserDefaults` so it survives app launches.
    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: User.storageKey)
    }

    /// Restores the cached user from `UserDefaults`, if one was saved.
    static func loadCached() -> User? {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }

    var description: String {
        """
            User(
            id: \(String(describing: id)), 
            name: \(name ?? "nil"),
            email: \(email ?? "nil"), 
            gender: \(gender ?? "nil"), 
            birthday: \(String(describing: birthday)),
            isInstructor: \(String(describing: isInstructor?.description))
            )
        """
    }
}

#if DEBUG
extension User {
    /// A populated, logged-in user for SwiftUI previews.
    static var preview: User {
        let user = User()
        user.id = 1
        user.name = "Troy McBarker"
        user.email = "someone@example.com"
        user.gender = "male"
        user.isInstructor = true
        return user
    }
}
#endif
