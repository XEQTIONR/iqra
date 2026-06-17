//
//  CourseScheduleView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-15.
//

import SwiftUI

/// Holds the single half-hour slot selected per day for a course schedule,
/// stored as minutes from midnight.
@Observable
final class CourseSchedule {
    var slots: [Day: Int] = [:]

    init(slots: [Day: Int] = [:]) {
        self.slots = slots
    }
}

struct CourseScheduleView: View {
    
    var format: CourseFormat
    var course: Course
    @Environment(Router.self) private var router
    @State private var schedule = CourseSchedule()
    @State private var selectedDay: Day = .mon
    @State private var callingApi: Bool = false
    @State private var openSlots: [Day: [Int]] = [:]

    private var selectedSlot: Int? {
        schedule.slots[selectedDay]
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Select your timeslot")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .fontWeight(.semibold)

            daySelector
                .padding(.vertical)

            scheduleCanvas
            Button("Continue") {
                print("format:", format)
            }
            .padding(.vertical)
        }
        .onAppear {
            Task {
                print("ZE YASK")
                guard !ProcessInfo.isRunningInPreview else {
                    return
                }
                print("gp YASK")
                
                do {
                    callingApi = true
                    let (data, _, ok) = try await RequestService.request(
                        "http://localhost:8000/api/courses/\(course.id!)/availabilities",
                        headers: RequestService.jsonHeaders
                    )
                    print("API CALL DATA")
                    print(String(data: data, encoding: .utf8) ?? "NONE")
                    
                    if ok {
                     // do sth
                        let availability = try RequestService.apiUnwrapCollection(type: Availability.self, from: data)
                        print("availability:", availability)
                        print("availability:", availability[0].toDictionary)
                        openSlots = availability[0].toDictionary
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
                let hasSlots = schedule.slots[day] != nil
                Button {
                    selectedDay = day
                } label: {
                    VStack(spacing: 4) {
                        Text(day.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.semibold)
                        Circle()
                            .fill(hasSlots ? Color.blue : Color.clear)
                            .frame(width: 5, height: 5)
                    }
                    .foregroundStyle(isSelected ? Color.white : Color.primary)
                }
                .frame(width: 45, height: 45)
                .background(isSelected ? Color.blue : Color.blue.opacity(0.15))
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
                    let isSelected = selectedSlot == slot.minutesFromMidnight
                    let available = (openSlots[selectedDay]?.contains(slot.minutesFromMidnight) ?? false)
                    Button {
                        toggle(slot)
                    } label: {
                        HStack {
                            Text(slot.label)
                                .font(.subheadline)
                                .monospacedDigit()
                                .foregroundStyle(isSelected ? Color.white : Color.primary)
                                .strikethrough(!available)
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
                    .disabled(!available)
                }
            }
            .padding(.bottom)
        }
    }

    private func toggle(_ slot: TimeSlot) {
        if schedule.slots[selectedDay] == slot.minutesFromMidnight {
            schedule.slots[selectedDay] = nil
        } else {
            schedule.slots[selectedDay] = slot.minutesFromMidnight
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
                price: 50.0,
                billingCycles: 10
            )],
        
        )
    )
        .environment(Router())
}
