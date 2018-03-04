//
//  VACalendar.swift
//  VACalendar
//
//  Created by Anton Vodolazkyi on 20.02.18.
//  Copyright © 2018 Vodolazkyi. All rights reserved.
//

import Foundation

protocol VACalendarDelegate: class {
    func selectedDaysDidUpdate(_ days: [VADay])
}

public enum DaysAvailability {
    case all
    case some([Date])
}

public class VACalendar {
    
    var months = [VAMonth]()
    weak var delegate: VACalendarDelegate?
    
    private let calendar: Calendar
    private var daysAvailability: DaysAvailability = .all
    
    private var selectedDays = [VADay]() {
        didSet {
            delegate?.selectedDaysDidUpdate(selectedDays)
        }
    }
    
    public init(
        startDate: Date? = nil,
        endDate: Date? = nil,
        selectedDate: Date? = Date(),
        calendar: Calendar = Calendar.current) {
        self.calendar = calendar
        
        if let selectedDate = selectedDate {
            let day = VADay(date: selectedDate, state: .selected, calendar: calendar)
            selectedDays = [day]
        }
        
        let startDate = startDate ?? calendar.date(byAdding: .year, value: -1, to: Date())!
        let endDate = endDate ?? calendar.date(byAdding: .year, value: 1, to: Date())!
        months = generateMonths(from: startDate, endDate: endDate)
    }
    
    func selectDay(_ day: VADay) {
        months.first(where: { $0.dateInThisMonth(day.date) })?.setDaySelectionState(day, state:.selected)
        selectedDays = [day]
    }
    
    func selectDates(_ dates: [Date]) {
        let days = months.flatMap { $0.days(for: dates) }
        days.forEach { $0.setSelectionState(.selected) }
        selectedDays = days
    }
    
    func setDaysAvailability(_ availability: DaysAvailability) {
        daysAvailability = availability
        
        switch availability {
        case .all:
            let days = months.flatMap { $0.allDays() }
            days.forEach { $0.setState(.available) }
            
        case .some(let dates):
            let allDays = months.flatMap { $0.allDays() }
            allDays.forEach { $0.setState(.unavailable) }
            let availableDays = dates.flatMap { date in allDays.filter { $0.dateInDay(date) }}
            availableDays.forEach { $0.setState(.available) }
        }
    }
    
    func setDaySelectionState(_ day: VADay, state: VADayState) {
        months.first(where: { $0.dateInThisMonth(day.date) })?.setDaySelectionState(day, state: state)
        
        if let index = selectedDays.index(of: day) {
            selectedDays.remove(at: index)
        } else {
            selectedDays.append(day)
        }
    }
    
    func setSupplementaries(_ data: [(Date, [VADaySupplementary])]) {
        let dates = data.map { $0.0 }
        let days = months.flatMap { $0.days(for: dates) }
        
        days.forEach { day in
            guard let supplementaries = data.first(where: { day.dateInDay($0.0) })?.1 else { return }
            day.set(supplementaries)
        }
    }
    
    func deselectAll() {
        selectedDays = []
        months.forEach { $0.deselectAll() }
    }
    
    private func generateMonths(from startDate: Date, endDate: Date) -> [VAMonth] {
        let startComponents = calendar.dateComponents([.year, .month], from: startDate)
        let endComponents = calendar.dateComponents([.year, .month], from: endDate)
        var startDate = calendar.date(from: startComponents)!
        let endDate = calendar.date(from: endComponents)!
        var months = [VAMonth]()
        
        repeat {
            let date = startDate
            let month = VAMonth(month: date, calendar: calendar)
            month.selectedDays = selectedDays.filter { calendar.isDate($0.date, equalTo: startDate, toGranularity: .month) }
            months.append(month)
            startDate = calendar.date(byAdding: .month, value: 1, to: date)!
        } while !calendar.isDate(startDate, inSameDayAs: endDate)
        
        return months
    }
    
}
