//
//  VAMonth.swift
//  VACalendar
//
//  Created by Anton Vodolazkyi on 20.02.18.
//  Copyright © 2018 Vodolazkyi. All rights reserved.
//

import Foundation

class VAMonth {
    
    var weeks = [VAWeek]()
    let lastMonthDay: Date
    let date: Date
    
    var isCurrent: Bool {
        return calendar.isDate(date, equalTo: Date(), toGranularity: .month)
    }
    
    var numberOfWeeks: Int {
        return weeks.count
    }
    
    var selectedDays = [VADay]() {
        didSet {
            self.weeks = generateWeeks()
        }
    }
    
    private let calendar: Calendar
    
    init(month: Date, calendar: Calendar) {
        self.date = month
        self.calendar = calendar
        self.lastMonthDay = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: date)!
    }
    
    func days(for dates: [Date]) -> [VADay] {
        return weeks.flatMap { $0.days(for: dates) }
    }
    
    func allDays() -> [VADay] {
        return weeks.flatMap { $0.days }.filter { $0.dayInMonth }
    }
    
    func dateInThisMonth(_ date: Date) -> Bool {
        return calendar.isDate(date, equalTo: self.date, toGranularity: .month)
    }
    
    func deselectAll() {
        weeks.forEach { $0.deselectAll() }
    }
    
    func setDaySelectionState(_ day: VADay, state: VADayState) {
        weeks.first(where: { $0.dateInThisWeek(day.date) })?.setDaySelectionState(day, state: state)
    }
    
    func set(_ day: VADay, supplementaries: [VADaySupplementary]) {
        weeks.first(where: { $0.dateInThisWeek(day.date) })?.set(day, supplementaries: supplementaries)
    }
    
    private func generateWeeks() -> [VAWeek] {
        var weeks = [VAWeek]()
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        var weekDay = calendar.date(from: components)!
        
        repeat {
            var days = [VADay]()
            for index in 0...6 {
                guard let dayInWeek = calendar.date(byAdding: .day, value: +index, to: weekDay) else { continue }
                let dayState = state(for: dayInWeek)
                let day = VADay(date: dayInWeek, state: dayState, calendar: calendar)
                days.append(day)
            }
            let week = VAWeek(days: days, date: weekDay, calendar: calendar)
            weeks.append(week)
            weekDay = calendar.date(byAdding: .weekOfYear, value: 1, to: weekDay)!
        } while calendar.isDate(weekDay, equalTo: lastMonthDay, toGranularity: .month)
        
        return weeks
    }
    
    private func state(for date: Date) -> VADayState {
        if !calendar.isDate(date, equalTo: lastMonthDay, toGranularity: .month) {
            return .out
        } else if selectedDays.contains(where: { calendar.isDate($0.date , inSameDayAs: date) }) {
            return .selected
        } else {
            return .available
        }
    }
    
}
