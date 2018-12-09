//
//  VAVerticalMonthPeriodType.swift
//  VACalendar
//
//  Created by Vodolazkyi Anton on 9/23/18.
//

import UIKit

public class VAVerticalMonthPeriodType: VAPeriodType {
    
    var monthVerticalInset: CGFloat = 20
    var monthVerticalHeaderHeight: CGFloat = 20
    
    private let numberDaysInWeek = 7

    override func calculateContentSize(for calendarView: VACalendarView) -> CGSize {
        let weekHeight = calendarView.frame.width / CGFloat(numberDaysInWeek)

        let monthsHeight: CGFloat = calendarView.calendar.months.enumerated().reduce(0) { result, item in
            let inset: CGFloat = item.offset == calendarView.calendar.months.count - 1  ? 0.0 : monthVerticalInset
            let height = CGFloat(item.element.numberOfWeeks) * weekHeight + inset + monthVerticalHeaderHeight
            return CGFloat(result) + height
        }        
        return CGSize(width: calendarView.frame.width, height: monthsHeight)
    }
    
    override func changePeriodType() -> VAPeriodType {
        return VAYearPeriodType(numberOfMonthInRow: 3)
    }
    
    override func drawMonths(in calendarView: VACalendarView) {
        let weekHeight = calendarView.frame.width / CGFloat(numberDaysInWeek)
        
        calendarView.monthViews.forEach { $0.clean() }
        calendarView.monthViews.enumerated().forEach { index, monthView in
            let y = index == 0 ? 0 : calendarView.monthViews[index - 1].frame.maxY + monthVerticalInset
            let height = (CGFloat(monthView.numberOfWeeks) * weekHeight) + monthVerticalHeaderHeight
            monthView.frame = CGRect(x: 0, y: y, width: calendarView.frame.width, height: height)
        }
    }
    
    override func getMonthView(in calendarView: VACalendarView, offset: CGPoint) -> VAMonthView? {
        return calendarView.monthViews.first(where: { $0.frame.midY >= offset.y })
    }
    
    override func drawWeeks(in monthView: VAMonthView) {
        let weekHeight = monthView.frame.width / CGFloat(numberDaysInWeek)
        let leftInset = monthView.monthViewAppearanceDelegate?.leftInset?() ?? 0
        let rightInset = monthView.monthViewAppearanceDelegate?.rightInset?() ?? 0
        let initialOffsetY = monthView.monthLabel?.frame.maxY ?? 0
        let weekViewWidth = monthView.frame.width - (leftInset + rightInset)
        
        var x: CGFloat = leftInset
        var y: CGFloat = monthView.monthLabel?.frame.maxY ?? 0
        
        monthView.weekViews.enumerated().forEach { index, week in
            week.frame = CGRect(
                x: leftInset,
                y: y,
                width: weekViewWidth,
                height: weekHeight
            )
            y = week.frame.maxY
            week.setupDays()
        }
    }
    
}
