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
    
    private let selection: Selection

    enum Selection {
        case single(Binding<Date?>)
        case multiple(Binding<Set<Date>>)
    }
    
    init(
        selectedDate: Binding<Date?>,
        events: Binding<[Date]>,
        canSelectDate: ((Date) -> Bool)?,
        canDeselectDate: ((Date) -> Bool)?,
        onSelectDate: ((Date) -> Void)?,
        onDeselectDate: ((Date) -> Void)?
    
    ) {
        self.selection = .single(selectedDate)
        self.canSelectDate = canSelectDate
        self.canDeselectDate = canDeselectDate
        self.onSelectDate = onSelectDate
        self.onDeselectDate = onDeselectDate
        self._events = events
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
            onDeselectDate: nil
        )
    }
    
    init(
        selectedDate: Binding<Date?>,
        events: Binding<[Date]>,
        onSelectDate: ((Date) -> Void)?,
        onDeselectDate: ((Date) -> Void)?
    
    ) {
        self.init(
            selectedDate: selectedDate,
            events: events,
            canSelectDate: nil,
            canDeselectDate: nil,
            onSelectDate: onSelectDate,
            onDeselectDate: onDeselectDate
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
        self._events = events
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

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.delegate = context.coordinator
        calendarView.calendar = Calendar.current
        calendarView.fontDesign = .rounded
        calendarView.availableDateRange = DateInterval(
            start: Date().addingTimeInterval(-60 * 60 * 24 * 365),
            end: Date().addingTimeInterval(60 * 60 * 24 * 365 * 2)
        )

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

        let dateComponents = events.map {
            Calendar.current.dateComponents([.year, .month, .day], from: $0)
        }
        uiView.reloadDecorations(forDateComponents: dateComponents, animated: false)
    }

    private func syncSelection(in calendarView: UICalendarView) {
        switch selection {
        case .single(let binding):
            guard let singleSelection = calendarView.selectionBehavior as? UICalendarSelectionSingleDate else { return }
            let newComponents = binding.wrappedValue.map {
                Calendar.current.dateComponents([.year, .month, .day], from: $0)
            }
            if singleSelection.selectedDate != newComponents {
                singleSelection.setSelected(newComponents, animated: false)
            }
        case .multiple(let binding):
            guard let multiSelection = calendarView.selectionBehavior as? UICalendarSelectionMultiDate else { return }
            let newComponents = binding.wrappedValue.map {
                Calendar.current.dateComponents([.year, .month, .day], from: $0)
            }
            if Set(multiSelection.selectedDates) != Set(newComponents) {
                multiSelection.setSelectedDates(Array(newComponents), animated: false)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate, UICalendarSelectionMultiDateDelegate {
        var parent: NativeCalendarView

        init(_ parent: NativeCalendarView) {
            self.parent = parent
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = dateComponents.date else { return nil }

            if parent.events.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                return .default(color: .blue, size: .small)
            }
            return nil
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
    NativeCalendarView(selectedDate: .constant(nil), events: .constant([
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
}

