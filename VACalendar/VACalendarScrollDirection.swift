//
//  VACalendarScrollDirection.swift
//  Pods-VACalendarExample
//
//  Created by Vodolazkyi Anton on 9/16/18.
//

import Foundation

public class VACalendarScrollDirection {
    
    unowned let calendarView: VACalendarView
    var periodType: VAPeriodType
    
    public init(calendarView: VACalendarView, periodType: VAPeriodType = VAPeriodType()) {
        self.calendarView = calendarView
        self.periodType = periodType
    }
    
    func nextMonth() {}
    func previousMonth() {}
    func changeViewType() {}
    func drawMonth(_ month: VAMonthView?) {}

    func getMonthView(with offset: CGPoint) -> VAMonthView? {
        return periodType.getMonthView(in: calendarView, offset: offset)
    }
    
    func drawMonths() {
        periodType.drawMonths(in: calendarView)
    }
    
    func calculateContentSize() {
        calendarView.contentSize = periodType.calculateContentSize(for: calendarView)
    }
    
    func scrollToMonth(_ month: VAMonthView?) {
        let offset = month?.frame.origin ?? .zero
        calendarView.setContentOffset(offset, animated: false)
    }
    
}
