//
//  ScheduleView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-19.
//

import SwiftUI

struct ScheduleView: View {

    @State private var enrollments: [Enrollment]
    @State private var eventDates: [Date] = []
    @State private var selectedDate: Date?
    
    @State private var startDate: Date?
    @State private var endDate: Date?
    
    let calendar = Calendar.current
    
    var currentEnrollments: [[Date]] {
        let things = enrollments.map{ $0.sessionDates(
            start: startDate ?? $0.startAt,
            end: endDate ?? $0.endAt ?? Calendar.current.date(byAdding: .month, value: 1, to: $0.startAt)!
        ) }
        
        return things
    }
    
    init() {
        enrollments = []
        eventDates = []
        selectedDate = nil
        
        guard let interval = calendar.dateInterval(of: .month, for: Date()) else { return }
        
        startDate = interval.start
        endDate = nil
    }
    
    
    @ViewBuilder
    private var classList: some View {
        ForEach(eventDates, id: \.self) { date in
            Text(date.description)
        }
        if selectedDate == nil {
            Text("NIL DTE")
        } else {
            Text(selectedDate!.description)
                .foregroundStyle(.blue)
            
            if eventDates.contains(where: { calendar.isDate($0, inSameDayAs: selectedDate!) }) {
                ForEach(enrollments, id: \.self.id) { enrollment in
                    VStack(spacing: 20) {
                        Text(enrollment.format!.course!.title)
                    }
                }
            }
        }
        
    }

    var body: some View {
        ScrollView {
            VStack {
                NativeCalendarView(
                    selectedDate: $selectedDate,
                    events: $eventDates,
                    onSelectDate: { date in
                        selectedDate = date
                    },
                    onDeselectDate: { _ in selectedDate = nil },
                    onPageChange: { components in
                        guard let monthStart = calendar.date(from: components) else { return }

                        startDate = monthStart
                        endDate = calendar.date(byAdding: .month, value: 1, to: monthStart)
                        eventDates = currentEnrollments.flatMap { $0 }
                    }
                )
                .padding(.horizontal)
                
                Divider()
                classList
            }
            .task {
                await loadEnrollments()
            }
        }
    }

    private func loadEnrollments() async {
        do {
            print("load enrollments")
            guard !ProcessInfo.isRunningInPreview else { return }
            
            let (data, _, ok) = try await RequestService.request(
                ENROLLMENTS_ENDPOINT,
                headers: RequestService.authJsonHeaders
            )
            
            guard ok else { return }

            enrollments = try RequestService
                .apiUnwrapCollection(type: Enrollment.self, from: data)
                .map {
                    var local = $0
                    local.endAt = Date()
                    return local
                }
            
            eventDates = enrollments.flatMap{ $0.sessionDates(start: $0.startAt, end: endDate) }
            
            print("Event Dates:", eventDates)
        } catch {
            print(error)
        }
    }
}

#Preview {
    ScheduleView()
}
