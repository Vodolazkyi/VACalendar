//
//  VAVerticalScrollDirection.swift
//
//  Created by Vodolazkyi Anton on 9/18/18.
//

import UIKit

public class VAVerticalScrollDirection: VACalendarScrollDirection {

    public override init(calendarView: VACalendarView, periodType: VAPeriodType = VAYearPeriodType(numberOfMonthInRow: 3)) {
        super.init(calendarView: calendarView, periodType: periodType)
    }
    
    override func drawMonth(_ month: VAMonthView?) {
        let extractedExpr: CGPoint = month?.frame.origin ?? .zero
        let offset = extractedExpr
        let first: ((offset: Int, element: VAMonthView)) -> Bool = { $0.element.frame.minY >= offset.y }
        guard let currentIndex = calendarView.monthViews.enumerated().first(where: first)?.offset else { return }
                
        //TODO: change number of preloading
        let visibleRect = CGRect(origin: calendarView.contentOffset, size: calendarView.frame.size)
        calendarView.monthViews.enumerated().forEach { index, month in
            if month.frame.intersects(visibleRect) {
                print(index)
                month.delegate = calendarView
                month.setupWeeksView(with: periodType, shouldShowMonthLabel: true)
            } else {
                month.clean()
            }
        }
    }
    
    override func changeViewType() {
        periodType = periodType.changePeriodType()
        calculateContentSize()
        drawMonths()
        calendarView.scrollToStartDate()
    }
    
    override func scrollToMonth(_ month: VAMonthView?) {
        var offset = month?.frame.origin ?? .zero
        offset.x = 0
        calendarView.setContentOffset(offset, animated: false)
    }
    
}
