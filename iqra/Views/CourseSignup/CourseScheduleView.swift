//
//  CourseScheduleView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-15.
//

import SwiftUI

struct CourseScheduleView: View {
    
    var format: CourseFormat
    var course: Course
    @Environment(Router.self) private var router
    @State private var schedule : [Day: Int] = [:]
    @State private var selectedDay: Day = .mon
    @State private var callingApi: Bool = false
    @State private var openSlots: [Day: [Date]] = [:]
    @State private var startDate = Calendar.current.startOfDay(for: Date())
    @State private var courseInstructorId: Int?

    private var selectedSlot: Int? {
        schedule[selectedDay]
    }
    
    private var slotsSelected: Bool {
        schedule.count == format.lessonsPerWeek
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Schedule")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .fontWeight(.semibold)
            
            
            DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                
            daySelector
                .padding(.vertical)

            scheduleCanvas
            
            NavigationLink {
                CourseSignupConfirmView(
                    format: format,
                    course: course,
                    schedule: schedule,
                    startDate: startDate
                )
            } label: {
                Text(slotsSelected ? "Continue" : "Select timeslots")
            }
            .disabled(!slotsSelected)
            .padding(.vertical)
        }
        .onAppear {
            Task {
                guard !ProcessInfo.isRunningInPreview else {
                    return
                }

                do {
                    callingApi = true
                    let (data, _, ok) = try await RequestService.request(
                        "http://localhost:8000/api/courses/\(course.id!)/availabilities",
                        headers: RequestService.jsonHeaders
                    )
                    print("API CALL DATA")
                    print(String(data: data, encoding: .utf8) ?? "NONE")
                    
                    if ok {
                        let availability = try RequestService.apiUnwrapCollection(type: Availability.self, from: data)
                        openSlots = availability[0].toDictWithTZ()
                        courseInstructorId = availability[0].instructorId
                    } else {
                        // error handle
                    }
                    callingApi = false
                } catch {
                    callingApi = false
                    print("ERROR API CALL")
                    print(error)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                   // router.push(.instructorFormComplete(settings))
                }) {
                    Image(systemName: "gear")
                        .renderingMode(.original)
                }
            }
        }
        .overlay {
            
            if callingApi {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)
                    .frame(width: 50, height: 50)
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .background(.black.opacity(callingApi ? 0.3 : 0))
    }

    private var daySelector: some View {
        HStack(spacing: 10) {
            ForEach(Day.allCases, id: \.self) { day in
                let isSelected = day == selectedDay
                let hasSlots = schedule[day] != nil
                Button {
                    selectedDay = day
                } label: {
                    VStack(spacing: 4) {
                        Text(day.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.semibold)
                        Circle()
                            .fill(hasSlots ? (isSelected ? .white : .blue) : .clear)
                            .frame(width: 5, height: 5)
                    }
                    .foregroundStyle(isSelected ? .white : .primary)
                }
                .frame(width: 45, height: 45)
                .background(isSelected ? .blue : .blue.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// The scheduling "canvas": a scrollable column of half-hour time blocks
    /// for the currently selected day. Tapping a block toggles availability.
    private var scheduleCanvas: some View {
        ScrollView {
            VStack(spacing: 4) {
                ForEach(TimeSlot.all) { slot in
                    let isOpen = isSlotOpen(slot, on: selectedDay)
                    let isSelected = selectedSlot == slot.minutesFromMidnight

                    if isOpen {
                        Button {
                            toggle(slot)
                        } label: {
                            HStack {
                                Text(slot.label)
                                    .font(.subheadline)
                                    .monospacedDigit()
                                    .foregroundStyle(isSelected ? Color.white : Color.primary)

                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.white)
                                }
                            }
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .background(isSelected ? Color.blue : Color.gray.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        .disabled(!isSelected && schedule.count >= format.lessonsPerWeek)
                    }
                }
            }
            .padding(.bottom)
        }
    }

    private func isSlotOpen(_ slot: TimeSlot, on day: Day) -> Bool {
        openSlots[day]?.contains { minutesFromMidnight(for: $0) == slot.minutesFromMidnight } ?? false
    }

    private func minutesFromMidnight(for date: Date) -> Int {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return Int(date.timeIntervalSince(startOfDay) / 60)
    }

    private func toggle(_ slot: TimeSlot) {
        if schedule[selectedDay] == slot.minutesFromMidnight {
            schedule[selectedDay] = nil
        } else {
            schedule[selectedDay] = slot.minutesFromMidnight
        }
    }
}

#Preview {
    CourseScheduleView(
        format: CourseFormat(
            title: "Title",
            description: "Description",
            unit: .lesson,
            lessonLength: 60,
            lessonsPerWeek: 2,
            totalLessons: 10,
            price: 50.0,
            billingCycles: 10
        ),
        course: Course(
            title: "Title",
            description: "Description",
            image: "",
            video: "",
            difficulty: .beginner,
            category: .reading,
            lengthType: .fixed,
            ageGroups: [.kids, .teens],
            isPublished: false,
            formats: [CourseFormat(
                title: "Title",
                description: "Description",
                unit: .lesson,
                lessonLength: 60,
                lessonsPerWeek: 2,
                totalLessons: 10,
                price: 50.0,
                billingCycles: 10,
            )],
        )
    )
        .environment(Router())
}
