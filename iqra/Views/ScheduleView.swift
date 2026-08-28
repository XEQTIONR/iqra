//
//  ScheduleView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-19.
//

import SwiftUI

struct ScheduleView: View {
    
    @Environment(ClassSession.self) private var classSession
    @Environment(User.self) private var currentUser

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
    
    init(enrollments: [Enrollment] = []) {
        _enrollments = State(initialValue: enrollments)
        _selectedDate = State(initialValue: nil)

        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: Date()) else {
            _eventDates = State(initialValue: [])
            return
        }

        _startDate = State(initialValue: interval.start)
        _endDate = State(initialValue: nil)
        _eventDates = State(initialValue: Self.eventDates(for: enrollments, in: interval, endDate: nil))
    }

    private static func eventDates(
        for enrollments: [Enrollment],
        in interval: DateInterval,
        endDate: Date?
    ) -> [Date] {
        enrollments.flatMap { enrollment in
            var start = enrollment.startAt
            if interval.start > start {
                start = interval.start
            }
            return enrollment.sessionDates(start: start, end: endDate)
        }
    }
    
    
    @ViewBuilder
    private var classList: some View {
        if let selectedDate,
           eventDates.contains(where: { calendar.isDate($0, inSameDayAs: selectedDate) }) {
            VStack {
                ForEach(enrollments.filter { $0.hasSessionOn(selectedDate) }, id: \.id) { enrollment in
                    enrollmentRow(enrollment, on: selectedDate)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func enrollmentRow(_ enrollment: Enrollment, on date: Date) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(enrollment.format?.course?.title ?? "Class")
                if let minutes = enrollment.sessionForDate(date) {
                    Text(minutes.description)
                }
                if let instructorName = enrollment.format?.course?.instructor?.name {
                    Text(instructorName)
                }
            }

            Spacer()

            Button("Join") {
                join(enrollment)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.blue.opacity(0.4))
        .cornerRadius(10)
    }

    private func join(_ enrollment: Enrollment) {
        guard
            let studentId = enrollment.user?.id,
            let formatId = enrollment.format?.id,
            let instructorId = enrollment.format?.course?.instructor?.id
        else {
            print("Enrollment is missing student or instructor")
            return
        }

        let isInstructor = currentUser.id == instructorId
        let isStudent = currentUser.id == studentId
        guard isInstructor || isStudent else {
            print("Not instructor or student")
            return
        }

        classSession.current = MyClass(
            studentId: studentId,
            instructorId: instructorId,
            courseFormatId: formatId
        )
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
                .padding()

                    
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

            enrollments = try RequestService.apiUnwrapCollection(type: Enrollment.self, from: data)
            
            print("ENROLLMENTS:")
            print(enrollments)

            if let interval = calendar.dateInterval(of: .month, for: .now) {
                eventDates = Self.eventDates(for: enrollments, in: interval, endDate: endDate)
            }
            
            print("Event Dates:", eventDates)
        } catch {
            print(error)
        }
    }
}

#Preview {
    ScheduleView(enrollments: Enrollment.previewEnrollments)
        .environment(User.preview)
        .environment(ClassSession())
}

