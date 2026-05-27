//
//  Surah.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-24.
//

import Foundation

struct Surah: Codable, Identifiable {
    let id: Int
    let name: String
    let type: String
    let total_verses: Int
    let verses: [Ayah]
}

struct Ayah: Codable, Identifiable {
    let id: Int
    let text: String
    let transliteration: String?
    let translation: String?
}

typealias Chapter = Surah
typealias Verse = Ayah
