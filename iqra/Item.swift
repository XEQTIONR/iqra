//
//  Item.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
