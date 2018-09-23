//
//  VAPeriodType.swift
//  Pods-VACalendarExample
//
//  Created by Vodolazkyi Anton on 9/16/18.
//

import UIKit

public class VAPeriodType {
    
    public init() { }
    
    func calculateContentSize(for calendarView: VACalendarView) -> CGSize {
        return .zero
    }
    
    func drawMonths(in calendarView: VACalendarView) { }
    func getMonthView(in calendarView: VACalendarView, offset: CGPoint) -> VAMonthView? {
        return nil
    }
    
    @discardableResult
    func nextPeriod() -> VAPeriodType {
        return VAPeriodType()
    }
    
    func drawWeeks(in monthView: VAMonthView) { }
    func scrollOffset(for month: VAMonthView?, date: Date) -> CGPoint {
        return month?.frame.origin ?? .zero
    }
    
}
