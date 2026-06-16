//
//  ZeContentView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-16.
//

import SwiftUI

struct ZeContentView: View {
    @State private var selectedDate: Date? = Date()
    @State private var events: [Date] = []
    
    var body: some View {
        VStack {
            // Native UICalendarView
            NativeCalendarView(
                selectedDate: $selectedDate,
                events: $events
            )
            .frame(height: 500)
        }
        .padding()
    }
}

#Preview {
    ZeContentView()
}
