//
//  AvailibilityFormView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-11.
//

import SwiftUI

enum Day: String, CaseIterable, Codable, Hashable {
    case mon, tue, wed, thu, fri, sat, sun
}

/// A single half-hour slot in the day, identified by the number of minutes
/// since midnight (e.g. 0 = 00:00, 30 = 00:30, 60 = 01:00 ...).
struct TimeSlot: Identifiable, Hashable {
    let minutesFromMidnight: Int

    var id: Int { minutesFromMidnight }

    /// All 48 half-hour slots that make up a full day.
    static let all: [TimeSlot] = stride(from: 0, to: 24 * 60, by: 30)
        .map { TimeSlot(minutesFromMidnight: $0) }

    var label: String {
        "\(Self.formatted(minutesFromMidnight)) - \(Self.formatted(minutesFromMidnight + 30))"
    }

    private static func formatted(_ minutes: Int) -> String {
        let normalized = minutes % (24 * 60)
        let hour24 = normalized / 60
        let minute = normalized % 60
        let period = hour24 < 12 ? "AM" : "PM"
        var hour12 = hour24 % 12
        if hour12 == 0 { hour12 = 12 }
        return String(format: "%d:%02d%@", hour12, minute, period)
    }
}

struct InstructorAvailibilityFormView: View {
    
    @Environment(Router.self) private var router
    @Bindable var settings: InstructorSettings
    @State private var selectedDay: Day = .mon
    /// Selected half-hour slots, keyed by day.
    @State private var availability: [Day: Set<Int>] = [:]

    private var selectedSlots: Set<Int> {
        availability[selectedDay] ?? []
    }

    init(settings: InstructorSettings) {
        self.settings = settings
        _availability = State(initialValue: settings.availability)
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Select your availibility")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .fontWeight(.semibold)

            daySelector
                .padding(.vertical)

            scheduleCanvas
            Button("Continue") {
                settings.availability = availability
                router.push(.instructorCourseTypeForm(settings))
            }
            .padding(.vertical)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    router.push(.instructorCourseTypeForm(settings))
                }) {
                    Image(systemName: "gear")
                        .renderingMode(.original)
                }
            }
        }
    }

    private var daySelector: some View {
        HStack(spacing: 10) {
            ForEach(Day.allCases, id: \.self) { day in
                let isSelected = day == selectedDay
                let hasSlots = !(availability[day] ?? []).isEmpty
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
                    let isSelected = selectedSlots.contains(slot.minutesFromMidnight)
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
                }
            }
            .padding(.bottom)
        }
    }

    private func toggle(_ slot: TimeSlot) {
        var slots = availability[selectedDay] ?? []
        if slots.contains(slot.minutesFromMidnight) {
            slots.remove(slot.minutesFromMidnight)
        } else {
            slots.insert(slot.minutesFromMidnight)
        }
        availability[selectedDay] = slots
    }
}

#Preview {
    InstructorAvailibilityFormView(settings: InstructorSettings())
        .environment(Router())
}
