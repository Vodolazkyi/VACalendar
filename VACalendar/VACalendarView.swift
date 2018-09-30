//
//  VACalendarView.swift
//  VACalendar
//
//  Created by Anton Vodolazkyi on 20.02.18.
//  Copyright © 2018 Vodolazkyi. All rights reserved.
//

import UIKit

public enum VASelectionStyle {
    case single, multi
}

@objc
public protocol VACalendarViewDelegate: class {
    // use this method for single selection style
    @objc optional func selectedDate(_ date: Date)
    // use this method for multi selection style
    @objc optional func selectedDates(_ dates: [Date])
}

public class VACalendarView: UIScrollView {
    
    public weak var monthDelegate: VACalendarMonthDelegate?
    public weak var dayViewAppearanceDelegate: VADayViewAppearanceDelegate?
    public weak var monthViewAppearanceDelegate: VAMonthViewAppearanceDelegate?
    public weak var calendarDelegate: VACalendarViewDelegate?
    
    public lazy var scrollDirection: VACalendarScrollDirection = VAVerticalScrollDirection(calendarView: self)
    
    public var startDate = Date()
    public var showDaysOut = true
    public var selectionStyle: VASelectionStyle = .single
    
    let calendar: VACalendar
    var monthViews = [VAMonthView]()
    
    private var currentMonth: VAMonthView? {
        return getMonthView(with: contentOffset)
    }
    
    public init(frame: CGRect, calendar: VACalendar) {
        self.calendar = calendar
        
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // specify all properties before calling setup()
    public func setup() {
        delegate = self
        calendar.delegate = self
        directionSetup()
        scrollDirection.calculateContentSize()
        setupMonths()
        scrollToStartDate()
    }
    
    public func nextMonth() {
        scrollDirection.nextMonth()
    }
    
    public func previousMonth() {
        scrollDirection.previousMonth()
    }
    
    public func selectDates(_ dates: [Date]) {
        calendar.deselectAll()
        calendar.selectDates(dates)
    }
    
    public func setAvailableDates(_ availability: DaysAvailability) {
        calendar.setDaysAvailability(availability)
    }
    
    public func setSupplementaries(_ data: [(Date, [VADaySupplementary])]) {
        calendar.setSupplementaries(data)
    }
    
    public func changeViewType() {
        scrollDirection.changeViewType()
    }
    
    func scrollToStartDate() {
        let startMonth = monthViews.first(where: { $0.month.dateInThisMonth(startDate) })
        
        scrollDirection.drawMonth(startMonth)
        scrollDirection.scrollToMonth(startMonth)
    }
    
    // MARK: Private Methods.
    
    private func directionSetup() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    private func setupMonths() {
        monthViews = calendar.months.map {
            VAMonthView(
                month: $0,
                showDaysOut: showDaysOut
            )
        }
        monthViews.forEach { addSubview($0) }
        scrollDirection.drawMonths()
    }
    
    private func getMonthView(with offset: CGPoint) -> VAMonthView? {
        return scrollDirection.getMonthView(with: offset)
    }
    
}

extension VACalendarView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let monthView = getMonthView(with: scrollView.contentOffset) else { return }
        
        monthDelegate?.monthDidChange(monthView.month.date)
        scrollDirection.drawMonth(monthView)
    }
    
}

extension VACalendarView: VACalendarDelegate {
    
    func selectedDaysDidUpdate(_ days: [VADay]) {
        let dates = days.map { $0.date }
        calendarDelegate?.selectedDates?(dates)
    }
    
}

extension VACalendarView: VAMonthViewDelegate {
    
    func dayStateChanged(_ day: VADay, in month: VAMonth) {
        switch selectionStyle {
        case .single:
            guard day.state == .available else { return }
            
            calendar.deselectAll()
            calendar.setDaySelectionState(day, state: .selected)
            calendarDelegate?.selectedDate?(day.date)
            
        case .multi:
            calendar.setDaySelectionState(day, state: day.reverseSelectionState)
        }
    }
    
}
