//
//  VAWeekPeriodType.swift
//  Pods-VACalendarExample
//
//  Created by Vodolazkyi Anton on 9/16/18.
//

import UIKit

public class VAWeekPeriodType: VAPeriodType {
    
    override func calculateContentSize(for calendarView: VACalendarView) -> CGSize {
        let width = calendarView.calendar.months.reduce(0) { sum, month -> CGFloat in
            return sum + (CGFloat(month.weeks.count) * calendarView.frame.width)
        }
        return CGSize(width: width, height: calendarView.contentSize.height)
    }
    
    override func drawMonths(in calendarView: VACalendarView) {
        calendarView.monthViews.forEach { $0.clean() }
        calendarView.monthViews.enumerated().forEach { index, monthView in
            let x = index == 0 ? 0 : calendarView.monthViews[index - 1].frame.maxX
            let monthWidth = calendarView.frame.width * CGFloat(monthView.numberOfWeeks)
            monthView.frame = CGRect(x: x, y: 0, width: monthWidth, height: calendarView.frame.height)
        }
    }
    
    override func getMonthView(in calendarView: VACalendarView, offset: CGPoint) -> VAMonthView? {
        let rect = CGRect(origin: offset, size: calendarView.frame.size)
        return calendarView.monthViews.first(where: { $0.frame.intersects(rect) })
    }
    
    override func nextPeriod() -> VAPeriodType {
        return VAMonthPeriodType()
    }
    
    override func drawWeeks(in monthView: VAMonthView) {
        let leftInset = monthView.monthViewAppearanceDelegate?.leftInset?() ?? 0
        let rightInset = monthView.monthViewAppearanceDelegate?.rightInset?() ?? 0
        let initialOffsetY = monthView.monthLabel?.frame.maxY ?? 0
        let weekViewWidth = monthView.frame.width - (leftInset + rightInset)
        
        var x: CGFloat = leftInset
        var y: CGFloat = initialOffsetY
        
        monthView.weekViews.enumerated().forEach { index, week in
            let width = monthView.superviewWidth - (leftInset + rightInset)
            
            week.frame = CGRect(
                x: x,
                y: initialOffsetY,
                width: width,
                height: monthView.weekHeight
            )
            x = week.frame.maxX + (leftInset + rightInset)
            week.setupDays()
        }
    }
    
    override func scrollOffset(for month: VAMonthView?, date: Date) -> CGPoint {
        var offset = month?.frame.origin ?? .zero
        let weekOffset = month?.week(with: date)?.frame.origin.x ?? 0
        let inset = month?.monthViewAppearanceDelegate?.leftInset?() ?? 0
        offset.x += weekOffset - inset
        return offset
    }
    
}
