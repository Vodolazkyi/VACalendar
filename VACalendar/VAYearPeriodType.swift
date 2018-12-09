//
//  VAYearPeriodType.swift
//  VACalendar
//
//  Created by Vodolazkyi Anton on 9/23/18.
//

import UIKit

public class VAYearPeriodType: VAPeriodType {
    
    let numberOfMonthInRow: Int
    var monthVerticalInset: CGFloat = 20
    var monthVerticalHeaderHeight: CGFloat = 20
    let maxNumberOfWeek: CGFloat = 6

    private let numberDaysInWeek = 7
    
    public init(numberOfMonthInRow: Int = 1) {
        self.numberOfMonthInRow = numberOfMonthInRow
        super.init()
    }
    
    override func calculateContentSize(for calendarView: VACalendarView) -> CGSize {
        let weekHeight = (calendarView.frame.width / CGFloat(numberOfMonthInRow)) / CGFloat(numberDaysInWeek)
        
        // Changed dynamic ('item.element.numberOfWeeks') number of week to 'maxNumberOfWeek'
//        let monthsHeight: CGFloat = calendarView.calendar.months.enumerated().reduce(0) { result, item in
//            let inset: CGFloat = item.offset == calendarView.calendar.months.count - 1  ? 0.0 : monthVerticalInset
//            let height = CGFloat(item.element.numberOfWeeks) * weekHeight + inset + monthVerticalHeaderHeight
//            return CGFloat(result) + height
//        }
        let rowsCount = CGFloat(calendarView.calendar.months.count / numberOfMonthInRow)
        let weekTopInset = monthVerticalHeaderHeight + monthVerticalInset
        let monthWeeksHeight = (weekHeight * maxNumberOfWeek) + weekTopInset
        let monthsHeight = rowsCount * monthWeeksHeight
        
        return CGSize(width: calendarView.contentSize.width, height: monthsHeight)
    }
    
    override func changePeriodType() -> VAPeriodType {
        return VAVerticalMonthPeriodType()
    }
    
    override func drawMonths(in calendarView: VACalendarView) {
        let weekWidth = calendarView.frame.width / CGFloat(numberOfMonthInRow)
        let weekHeight = (weekWidth / CGFloat(numberDaysInWeek))
        let height = weekHeight * CGFloat(maxNumberOfWeek)
            
        calendarView.monthViews.forEach { $0.clean() }
        calendarView.monthViews.enumerated().forEach { index, monthView in
            if index % numberOfMonthInRow == 0 {
                let y = index == 0 ?
                    monthVerticalHeaderHeight : calendarView.monthViews[index - 1].frame.maxY + monthVerticalHeaderHeight + monthVerticalInset
                monthView.frame = CGRect(x: 0, y: y, width: weekWidth, height: height)
            } else {
                let x = (calendarView.frame.width / CGFloat(numberOfMonthInRow)) * CGFloat(index % numberOfMonthInRow)
                monthView.frame = CGRect(x: x, y: calendarView.monthViews[index - 1].frame.origin.y, width: weekWidth, height: height)
            }
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
