//
//  ScheduleView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-19.
//

import SwiftUI

struct ScheduleView: View {

    @State private var enrollments: [Enrollment] = []
    @State private var eventDates: [Date] = []
    @State private var selectedDate: Date?
    
    let calendar = Calendar.current
    
    var selectedEnrollments: [Enrollment] {
        guard let selectedDate else { return [] }
        
        return enrollments.filter { $0.sessionDates.contains(selectedDate) }
    }
    
    @ViewBuilder
    private var classList: some View {
        
        ForEach(eventDates, id: \.self) { date in
            Text(date.description)
        }
        if selectedDate == nil {
            Text("NIL DTE")
        } else if selectedDate != nil {
            
            Text(selectedDate?.description ?? "NONE")
                .foregroundStyle(.blue)
            if eventDates.contains(selectedDate!) {
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
                        print("SELECTED:", selectedDate)
                    },
                    onDeselectDate: { _ in selectedDate = nil }
                )
                .frame(width: 350, height: 450)
                
                classList
            }
            .task {
                await loadEnrollments()
            }
        }
    }

    private func loadEnrollments() async {
        do {
            
            guard !ProcessInfo.isRunningInPreview else {
                return
            }
            
            let (data, _, ok) = try await RequestService.request(
                ENROLLMENTS_ENDPOINT,
                headers: RequestService.authJsonHeaders
            )
            guard ok else { return }

            enrollments = try RequestService.apiUnwrapCollection(type: Enrollment.self, from: data)
            eventDates = enrollments.flatMap { $0.sessionDates }
            print ("enrollments:", enrollments)
            print("Event Dates:", eventDates)
        } catch {
            print(error)
        }
    }
}

#Preview {
    ScheduleView()
}
