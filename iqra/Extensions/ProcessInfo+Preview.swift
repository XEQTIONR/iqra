//
//  ProcessInfo+Preview.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-12.
//

import Foundation

extension ProcessInfo {
    static var isRunningInPreview: Bool {
        processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
