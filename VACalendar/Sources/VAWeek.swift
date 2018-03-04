//
//  VAWeek.swift
//  VACalendar
//
//  Created by Anton Vodolazkyi on 20.02.18.
//  Copyright © 2018 Vodolazkyi. All rights reserved.
//

import Foundation

class VAWeek {
    
    var days: [VADay]
    let date: Date
    
    private let calendar: Calendar
    
    init(days: [VADay], date: Date, calendar: Calendar) {
        self.days = days
        self.date = date
        self.calendar = calendar
    }

    func days(for dates: [Date]) -> [VADay] {
        return dates.flatMap { date in days.filter { $0.dateInDay(date) && $0.isSelectable }}
    }
    
    func dateInThisWeek(_ date: Date) -> Bool {
        return calendar.isDate(date, equalTo: self.date, toGranularity: .weekOfYear)
    }
    
    func deselectAll() {
        days.forEach { $0.setSelectionState(.available) }
    }
    
    func setDaySelectionState(_ day: VADay, state: VADayState)  {
        days.first(where: { $0.dateInDay(day.date) })?.setSelectionState(state)
    }
    
    func set(_ day: VADay, supplementaries: [VADaySupplementary]) {
        days.first(where: { $0.dateInDay(day.date) })?.set(supplementaries)
    }
    
}
