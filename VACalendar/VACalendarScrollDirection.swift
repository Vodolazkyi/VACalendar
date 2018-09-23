//
//  VACalendarScrollDirection.swift
//  Pods-VACalendarExample
//
//  Created by Vodolazkyi Anton on 9/16/18.
//

import Foundation

public class VACalendarScrollDirection {
    
    var weekHeight: CGFloat {
        return 0.0
    }
    
    unowned let calendarView: VACalendarView
    var periodType: VAPeriodType
    
    public init(calendarView: VACalendarView, periodType: VAPeriodType = VAPeriodType()) {
        self.calendarView = calendarView
        self.periodType = periodType
    }
    
    func nextMonth() {}
    func previousMonth() {}
    func changeViewType() {}
    func calculateContentSize() {}
    func drawMonths() {}
    func getMonthView(with offset: CGPoint) -> VAMonthView? {
        return nil
    }
    func drawMonth(_ month: VAMonthView?) {}
    func scrollToMonth(_ month: VAMonthView?) {
        let offset = month?.frame.origin ?? .zero
        calendarView.setContentOffset(offset, animated: false)
    }
    
}
