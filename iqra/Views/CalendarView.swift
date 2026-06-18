//
//  CalendarView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI

struct CalendarView: View {
    var body: some View {
        
        VStack{
            NativeCalendarView(
                selectedDates: .constant([]),
                events: .constant([
                    Date().addingTimeInterval(60 * 60 * 24 * 2),
                    Date().addingTimeInterval(60 * 60 * 24 * 5),
                ]),
                canSelectDate: {_ in true},
                canDeselectDate: {_ in true}
            )
            .frame(height: 500)
        }

    }
}

#Preview {
    CalendarView()
}
