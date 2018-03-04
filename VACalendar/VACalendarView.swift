//
//  VACalendarView.swift
//  VACalendar
//
//  Created by Anton Vodolazkyi on 20.02.18.
//  Copyright © 2018 Vodolazkyi. All rights reserved.
//

import UIKit

public enum VASelectionStyle {
    case single
    case multi
}

public enum VACalendarScrollDirection {
    case horizontal, vertical
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
    
    public var scrollDirection: VACalendarScrollDirection = .vertical
    // use this for vertical scroll direction
    public var monthVerticalInset: CGFloat = 20
    public var monthVerticalHeaderHeight: CGFloat = 20
    
    public var startDate = Date()
    public var showDaysOut = true
    public var selectionStyle: VASelectionStyle = .single
    
    private var calculatedWeekHeight: CGFloat = 100
    private let calendar: VACalendar
    private var monthViews = [VAMonthView]()
    private let maxNumberOfWeek = 6
    private let numberDaysInWeek = 7
    private var weekHeight: CGFloat {
        switch scrollDirection {
        case .horizontal:
            return frame.height / CGFloat(maxNumberOfWeek)
        case .vertical:
            return frame.width / CGFloat(numberDaysInWeek)
        }
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
        calculateContentSize()
        setupMonths()
        scrollToStartDate()
    }
    
    public func nextMonth() {
        switch scrollDirection {
        case .horizontal:
            let x = contentOffset.x + frame.width
            guard x < contentSize.width else { return }
            
            setContentOffset(CGPoint(x: x, y: 0), animated: false)
            drawVisibleMonth(with: contentOffset)
        case .vertical: break
        }
    }
    
    public func previousMonth() {
        switch scrollDirection {
        case .horizontal:
            let x = contentOffset.x - frame.width
            guard x >= 0 else { return }
            
            setContentOffset(CGPoint(x: x, y: 0), animated: false)
            drawVisibleMonth(with: contentOffset)
        case .vertical: break
        }
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
    
    private func directionSetup() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        switch scrollDirection {
        case .horizontal:
            isPagingEnabled = true
        case .vertical: break
        }
    }
    
    private func calculateContentSize() {
        switch scrollDirection {
        case .horizontal:
            contentSize.width = frame.width * CGFloat(calendar.months.count)
        case .vertical:
            let monthsHeight: CGFloat = calendar.months.enumerated().reduce(0) { result, item in
                let inset: CGFloat = item.offset == calendar.months.count - 1  ? 0.0 : monthVerticalInset
                let height = CGFloat(item.element.numberOfWeeks) * weekHeight + inset + monthVerticalHeaderHeight
                return CGFloat(result) + height
            }
            contentSize.height = monthsHeight
        }
    }
    
    private func setupMonths() {
        monthViews = calendar.months.map { VAMonthView(month: $0, showDaysOut: showDaysOut, weekHeight: weekHeight) }
        
        monthViews.enumerated().forEach { index, monthView in
            switch scrollDirection {
            case .horizontal:
                let x = index == 0 ? 0 : monthViews[index - 1].frame.maxX
                monthView.frame = CGRect(x: x, y: 0, width: self.frame.width, height: self.frame.height)
            case .vertical:
                let y = index == 0 ? 0 : monthViews[index - 1].frame.maxY + monthVerticalInset
                let height = (CGFloat(monthView.numberOfWeeks) * weekHeight) + monthVerticalHeaderHeight
                monthView.frame = CGRect(x: 0, y: y, width: self.frame.width, height: height)
            }
            self.addSubview(monthView)
        }
    }
    
    private func scrollToStartDate() {
        let startMonth = monthViews.first(where: { $0.month.dateInThisMonth(startDate) })
        
        if let startMonth = startMonth {
            setContentOffset(startMonth.frame.origin, animated: false)
        } else {
            setContentOffset(.zero, animated: false)
        }
        drawVisibleMonth(with: contentOffset)
    }
    
    private func getMonthView(with offset: CGPoint) -> VAMonthView? {
        switch scrollDirection {
        case .horizontal:
            return monthViews.first(where: { $0.frame.midX >= offset.x })
        case .vertical:
            return monthViews.first(where: { $0.frame.midY >= offset.y })
        }
    }
    
    private func drawVisibleMonth(with offset: CGPoint) {
        switch scrollDirection {
        case .horizontal:
            let first: ((offset: Int, element: VAMonthView)) -> Bool = { $0.element.frame.midX >= offset.x }
            guard let currentIndex = monthViews.enumerated().first(where: first)?.offset else { return }
            
            monthViews.enumerated().forEach { index, month in
                if index == currentIndex || index + 1 == currentIndex || index - 1 == currentIndex {
                    month.delegate = self
                    month.drawWeeksView()
                } else {
                    month.clean()
                }
            }
            
        case .vertical:
            let first: ((offset: Int, element: VAMonthView)) -> Bool = { $0.element.frame.minY >= offset.y }
            guard let currentIndex = monthViews.enumerated().first(where: first)?.offset else { return }
            
            monthViews.enumerated().forEach { index, month in
                if index >= currentIndex - 1 && index <= currentIndex + 1 {
                    month.delegate = self
                    month.drawWeeksView()
                } else {
                    month.clean()
                }
            }
        }
    }
    
}

extension VACalendarView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let monthView = getMonthView(with: scrollView.contentOffset) else { return }
        
        monthDelegate?.monthDidChange(monthView.month.date)
        drawVisibleMonth(with: scrollView.contentOffset)
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
