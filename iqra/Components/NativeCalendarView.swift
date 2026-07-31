//
//  NativeCalendarView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-16.
//

import SwiftUI
import UIKit

struct NativeCalendarView: UIViewRepresentable {
    @Binding var events: [Date]
    
    let canSelectDate: ((Date) -> Bool)?
    let canDeselectDate: ((Date) -> Bool)?
    let onSelectDate: ((Date) -> Void)?
    let onDeselectDate: ((Date) -> Void)?
    let onPageChange: ((DateComponents) -> Void)?
    
    private let month: Int?
    private let year: Int?
    private let date: Date
    
    private let selection: Selection

    enum Selection {
        case single(Binding<Date?>)
        case multiple(Binding<Set<Date>>)
    }
    
    // single selection 
    init(
        selectedDate: Binding<Date?>,
        events: Binding<[Date]>,
        canSelectDate: ((Date) -> Bool)?,
        canDeselectDate: ((Date) -> Bool)?,
        onSelectDate: ((Date) -> Void)?,
        onDeselectDate: ((Date) -> Void)?,
        onPageChange: ((DateComponents) -> Void)?
    
    ) {
        self.selection = .single(selectedDate)
        self.canSelectDate = canSelectDate
        self.canDeselectDate = canDeselectDate
        self.onSelectDate = onSelectDate
        self.onDeselectDate = onDeselectDate
        self.onPageChange = onPageChange
        self._events = events
        
        let date = selectedDate.wrappedValue ?? Date()
        
        self.date = date
        self.month = Calendar.current.component(.month, from: date)
        self.year = Calendar.current.component(.year, from: date)
    }
    
    
    init(
        selectedDate: Binding<Date?>,
        events: Binding<[Date]>,
        canSelectDate: ((Date) -> Bool)?,
        canDeselectDate: ((Date) -> Bool)?,
    ) {
        self.init(
            selectedDate: selectedDate,
            events: events,
            canSelectDate: canSelectDate,
            canDeselectDate: canDeselectDate,
            onSelectDate: nil,
            onDeselectDate: nil,
            onPageChange: nil
        )
    }
    
    init(
        selectedDate: Binding<Date?>,
        events: Binding<[Date]>,
        onSelectDate: ((Date) -> Void)?,
        onDeselectDate: ((Date) -> Void)?,
        onPageChange: ((DateComponents) -> Void)?
    
    ) {
        self.init(
            selectedDate: selectedDate,
            events: events,
            canSelectDate: nil,
            canDeselectDate: nil,
            onSelectDate: onSelectDate,
            onDeselectDate: onDeselectDate,
            onPageChange: onPageChange
        )
    }
    
    init(
        selectedDate: Binding<Date?>,
        events: Binding<[Date]>,
    ) {
        self.init(
            selectedDate: selectedDate,
            events: events,
            canSelectDate: nil,
            canDeselectDate: nil,
        )
    }

    // multiple selection
    init(
        selectedDates: Binding<Set<Date>>,
        events: Binding<[Date]>,
        canSelectDate: ((Date) -> Bool)?,
        canDeselectDate: ((Date) -> Bool)?,
        onSelectDate: ((Date) -> Void)?,
        onDeselectDate: ((Date) -> Void)?
    ) {
        self.selection = .multiple(selectedDates)
        self.canSelectDate = canSelectDate
        self.canDeselectDate = canDeselectDate
        self.onSelectDate = onSelectDate
        self.onDeselectDate = onDeselectDate
        self.onPageChange = nil
        self._events = events
        
        let date = Date()
        self.date = date
        self.month = Calendar.current.component(.month, from: date)
        self.year = Calendar.current.component(.year, from: date)
    }
    
    init(
        selectedDates: Binding<Set<Date>>,
        events: Binding<[Date]>,
        canSelectDate: ((Date) -> Bool)?,
        canDeselectDate: ((Date) -> Bool)?,
    ) {
        self.init(
            selectedDates: selectedDates,
            events: events,
            canSelectDate: canSelectDate,
            canDeselectDate: canDeselectDate,
            onSelectDate: nil,
            onDeselectDate: nil
        )
    }
    
    init(
        selectedDates: Binding<Set<Date>>,
        events: Binding<[Date]>,
        onSelectDate: ((Date) -> Void)?,
        onDeselectDate: ((Date) -> Void)?
    ) {
        self.init(
            selectedDates: selectedDates,
            events: events,
            canSelectDate: nil,
            canDeselectDate: nil,
            onSelectDate: onSelectDate,
            onDeselectDate: onDeselectDate,
        )
    }
    
    init(
        selectedDates: Binding<Set<Date>>,
        events: Binding<[Date]>,
    ) {
        self.init(
            selectedDates: selectedDates,
            events: events,
            canSelectDate: nil,
            canDeselectDate: nil,
        )
    }
    
    
    /// Reduces components to just year/month/day so that values produced here can be
    /// compared against the ones `UICalendarView` hands back, which also carry
    /// `era`, `calendar` and `timeZone`.
    private static func dayComponents(of date: Date) -> DateComponents {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return DateComponents(year: components.year, month: components.month, day: components.day)
    }

    private static func normalized(_ components: DateComponents?) -> DateComponents? {
        guard let components else { return nil }
        return DateComponents(year: components.year, month: components.month, day: components.day)
    }

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        
        
        calendarView.delegate = context.coordinator
        calendarView.calendar = Calendar.current
        calendarView.fontDesign = .rounded
        calendarView.setVisibleDateComponents(DateComponents(year: year, month: month), animated: false)
        calendarView.availableDateRange = DateInterval(
            start: Date().addingTimeInterval(-60 * 60 * 24 * 365),
            end: Date().addingTimeInterval(60 * 60 * 24 * 365 * 2)
        )
        
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        switch selection {
        case .single:
            calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        case .multiple:
            calendarView.selectionBehavior = UICalendarSelectionMultiDate(delegate: context.coordinator)
        }

        return calendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.parent = self
        syncSelection(in: uiView)

        let eventComponents = events.map(Self.dayComponents(of:))
        if let changed = context.coordinator.decorationsToReload(for: eventComponents) {
            uiView.reloadDecorations(forDateComponents: changed, animated: false)
        }
    }

    private func syncSelection(in calendarView: UICalendarView) {
        switch selection {
        case .single(let binding):
            guard let singleSelection = calendarView.selectionBehavior as? UICalendarSelectionSingleDate else { return }
            let newComponents = binding.wrappedValue.map(Self.dayComponents(of:))
            // Re-selecting scrolls the calendar to the selected month, so only touch
            // the selection when the day it points at actually changed.
            guard Self.normalized(singleSelection.selectedDate) != newComponents else { return }
            singleSelection.setSelected(newComponents, animated: false)
        case .multiple(let binding):
            guard let multiSelection = calendarView.selectionBehavior as? UICalendarSelectionMultiDate else { return }
            let newComponents = binding.wrappedValue.map(Self.dayComponents(of:))
            let currentComponents = multiSelection.selectedDates.compactMap { Self.normalized($0) }
            guard Set(currentComponents) != Set(newComponents) else { return }
            multiSelection.setSelectedDates(newComponents, animated: false)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate, UICalendarSelectionMultiDateDelegate {
        var parent: NativeCalendarView

        /// Page and decoration state has to live on the coordinator: the `parent` struct is
        /// replaced on every SwiftUI update, so anything stored on it is lost.
        private var visiblePage: DateComponents?
        private var decoratedComponents: Set<DateComponents> = []

        init(_ parent: NativeCalendarView) {
            self.parent = parent
        }

        /// Returns the components whose decoration changed, or `nil` when nothing changed.
        func decorationsToReload(for components: [DateComponents]) -> [DateComponents]? {
            let updated = Set(components)
            guard updated != decoratedComponents else { return nil }
            let changed = updated.symmetricDifference(decoratedComponents)
            decoratedComponents = updated
            return Array(changed)
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = dateComponents.date else { return nil }

            if parent.events.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                return .default(color: .blue, size: .small)
            }
            return nil
        }
        
        func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
            let components = DateComponents(year: calendarView.visibleDateComponents.year, month: calendarView.visibleDateComponents.month)

            guard components != visiblePage else { return }
            visiblePage = components

            guard let onPageChange = parent.onPageChange else { return }
            // This fires while the page transition is still running; letting the callback
            // mutate SwiftUI state synchronously re-enters updateUIView mid-scroll.
            DispatchQueue.main.async { onPageChange(components) }
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
            if let date = dateComponents?.date {
                guard let canSelectDate = parent.canSelectDate else { return true }
                return canSelectDate(date)
            }

            guard case .single(let binding) = parent.selection,
                  let selected = binding.wrappedValue else { return true }
            guard let canDeselectDate = parent.canDeselectDate else { return true }
            return canDeselectDate(selected)
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard case .single(let binding) = parent.selection else { return }

            if let date = dateComponents?.date {
                binding.wrappedValue = date
                parent.onSelectDate?(date)
            } else {
                let deselected = binding.wrappedValue
                binding.wrappedValue = nil
                if let deselected {
                    parent.onDeselectDate?(deselected)
                }
            }
        }

        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, canSelectDate dateComponents: DateComponents) -> Bool {
            guard let date = dateComponents.date else { return false }
            guard let canSelectDate = parent.canSelectDate else { return true }
            return canSelectDate(date)
        }

        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, canDeselectDate dateComponents: DateComponents) -> Bool {
            guard let date = dateComponents.date else { return false }
            guard let canDeselectDate = parent.canDeselectDate else { return true }
            return canDeselectDate(date)
        }

        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
            guard case .multiple(let binding) = parent.selection,
                  let date = dateComponents.date else { return }
            var dates = binding.wrappedValue
            dates.insert(Calendar.current.startOfDay(for: date))
            binding.wrappedValue = dates
            parent.onSelectDate?(date)
        }

        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
            guard case .multiple(let binding) = parent.selection,
                  let date = dateComponents.date else { return }
            let dayStart = Calendar.current.startOfDay(for: date)
            binding.wrappedValue = binding.wrappedValue.filter {
                !Calendar.current.isDate($0, inSameDayAs: dayStart)
            }
            parent.onDeselectDate?(date)
        }
    }
}

#Preview("Single selection") {
    NativeCalendarView(selectedDate: .constant(Date().addingTimeInterval(60 * 60 * 24 * 2)), events: .constant([
        Date().addingTimeInterval(60 * 60 * 24 * 2),
    ]))
}

#Preview("Multi selection") {
    NativeCalendarView(
        selectedDates: .constant([]),
        events: .constant([
            Date().addingTimeInterval(60 * 60 * 24 * 2),
            Date().addingTimeInterval(60 * 60 * 24 * 5),
        ]),
        canSelectDate: {_ in true},
        canDeselectDate: {_ in true}
    )
    .frame(width: 350, height: 500)
}

