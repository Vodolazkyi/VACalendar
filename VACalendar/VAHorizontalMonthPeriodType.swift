//
//  VAMonthPeriodType.swift
//  Pods-VACalendarExample
//
//  Created by Vodolazkyi Anton on 9/16/18.
//

import UIKit

public class VAHorizontalMonthPeriodType: VAPeriodType {
    
    private let maxNumberOfWeek: CGFloat = 6
    
    override func calculateContentSize(for calendarView: VACalendarView) -> CGSize {
        let width = calendarView.frame.width * CGFloat(calendarView.calendar.months.count)
        return CGSize(width: width, height: calendarView.contentSize.height)
    }
    
    override func drawMonths(in calendarView: VACalendarView) {
        calendarView.monthViews.forEach { $0.clean() }
        calendarView.monthViews.enumerated().forEach { index, monthView in
            let x = index == 0 ? 0 : calendarView.monthViews[index - 1].frame.maxX
            monthView.frame = CGRect(x: x, y: 0, width: calendarView.frame.width, height: calendarView.frame.height)
        }
    } 
    
    override func getMonthView(in calendarView: VACalendarView, offset: CGPoint) -> VAMonthView? {
        return calendarView.monthViews.first(where: { $0.frame.midX >= offset.x })
    }
    
    override func changePeriodType() -> VAPeriodType {
        return VAWeekPeriodType()
    }
    
    override func drawWeeks(in monthView: VAMonthView) {
        let weekHeight = monthView.frame.height / maxNumberOfWeek
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
