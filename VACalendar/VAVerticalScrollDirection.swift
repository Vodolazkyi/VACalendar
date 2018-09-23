//
//  VAVerticalScrollDirection.swift
//
//  Created by Vodolazkyi Anton on 9/18/18.
//

import UIKit

public class VAVerticalScrollDirection: VACalendarScrollDirection {
    
    public var monthVerticalInset: CGFloat = 20
    public var monthVerticalHeaderHeight: CGFloat = 20
    
    private let numberDaysInWeek = 7
    
    override var weekHeight: CGFloat {
        return calendarView.frame.width / CGFloat(numberDaysInWeek)
    }
    
    public override init(calendarView: VACalendarView, periodType: VAPeriodType = VAMonthPeriodType()) {
        super.init(calendarView: calendarView, periodType: periodType)
    }
    
    override func calculateContentSize() {
        let monthsHeight: CGFloat = calendarView.calendar.months.enumerated().reduce(0) { result, item in
            let inset: CGFloat = item.offset == calendarView.calendar.months.count - 1  ? 0.0 : monthVerticalInset
            let height = CGFloat(item.element.numberOfWeeks) * weekHeight + inset + monthVerticalHeaderHeight
            return CGFloat(result) + height
        }
        calendarView.contentSize.height = monthsHeight
    }
    
    override func drawMonths() {
        calendarView.monthViews.forEach { $0.clean() }
        calendarView.monthViews.enumerated().forEach { index, monthView in
            let y = index == 0 ? 0 : calendarView.monthViews[index - 1].frame.maxY + monthVerticalInset
            let height = (CGFloat(monthView.numberOfWeeks) * weekHeight) + monthVerticalHeaderHeight
            monthView.frame = CGRect(x: 0, y: y, width: calendarView.frame.width, height: height)
        }
    }
    
    override func getMonthView(with offset: CGPoint) -> VAMonthView? {
        return calendarView.monthViews.first(where: { $0.frame.midY >= offset.y })
    }
    
    override func drawMonth(_ month: VAMonthView?) {
        let offset = month?.frame.origin ?? .zero
        let first: ((offset: Int, element: VAMonthView)) -> Bool = { $0.element.frame.minY >= offset.y }
        guard let currentIndex = calendarView.monthViews.enumerated().first(where: first)?.offset else { return }
        
        calendarView.monthViews.enumerated().forEach { index, month in
            if index >= currentIndex - 1 && index <= currentIndex + 1 {
                month.delegate = calendarView
                month.setupWeeksView(with: periodType, shouldShowMonthLabel: true)
            } else {
                month.clean()
            }
        }
    }
    
}
