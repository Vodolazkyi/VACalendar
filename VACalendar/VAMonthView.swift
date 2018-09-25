//
//  VAMonthView.swift
//  VACalendar
//
//  Created by Anton Vodolazkyi on 20.02.18.
//  Copyright © 2018 Vodolazkyi. All rights reserved.
//

import UIKit

protocol VAMonthViewDelegate: class {
    func dayStateChanged(_ day: VADay, in month: VAMonth)
}

@objc
public protocol VAMonthViewAppearanceDelegate: class {
    @objc optional func leftInset() -> CGFloat
    @objc optional func rightInset() -> CGFloat
    @objc optional func verticalMonthTitleFont() -> UIFont
    @objc optional func verticalMonthTitleColor() -> UIColor
    @objc optional func verticalCurrentMonthTitleColor() -> UIColor
    @objc optional func verticalMonthDateFormater() -> DateFormatter
}

class VAMonthView: UIView {
    
    var numberOfWeeks: Int {
        return month.numberOfWeeks
    }
    
    var isDrawn: Bool {
        return !weekViews.isEmpty
    }
    
    var scrollDirection: VACalendarScrollDirection {
        return (superview as? VACalendarView)?.scrollDirection ?? .horizontal
    }
    
    var monthVerticalHeaderHeight: CGFloat {
        return (superview as? VACalendarView)?.monthVerticalHeaderHeight ?? 0.0
    }
    
    var superviewWidth: CGFloat {
        return superview?.frame.width ?? 0
    }
    
    weak var monthViewAppearanceDelegate: VAMonthViewAppearanceDelegate? {
        return (superview as? VACalendarView)?.monthViewAppearanceDelegate
    }
    
    weak var dayViewAppearanceDelegate: VADayViewAppearanceDelegate? {
        return (superview as? VACalendarView)?.dayViewAppearanceDelegate
    }
    
    weak var delegate: VAMonthViewDelegate?

    let month: VAMonth
    
    private let showDaysOut: Bool
    private var monthLabel: UILabel?
    private var weekViews = [VAWeekView]()
    private let weekHeight: CGFloat
    private var viewType: VACalendarViewType
    
    init(month: VAMonth, showDaysOut: Bool, weekHeight: CGFloat, viewType: VACalendarViewType) {
        self.month = month
        self.showDaysOut = showDaysOut
        self.weekHeight = weekHeight
        self.viewType = viewType
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWeeksView(with type: VACalendarViewType) {
        guard isDrawn == false else { return }
    
        self.viewType = type
        
        if scrollDirection == .vertical {
            setupMonthLabel()
        }

        self.weekViews = []

        month.weeks.enumerated().forEach { index, week in
            let weekView = VAWeekView(week: week, showDaysOut: showDaysOut)
            weekView.delegate = self
            self.weekViews.append(weekView)
            self.addSubview(weekView)
        }
        
        draw()
    }
    
    func clean() {
        monthLabel = nil
        weekViews = []
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    func week(with date: Date) -> VAWeekView? {
        return weekViews.first(where: { $0.contains(date: date) })
    }

    private func draw() {
        let leftInset = monthViewAppearanceDelegate?.leftInset?() ?? 0
        let rightInset = monthViewAppearanceDelegate?.rightInset?() ?? 0
        let initialOffsetY = self.monthLabel?.frame.maxY ?? 0
        let weekViewWidth = self.frame.width - (leftInset + rightInset)
        
        var x: CGFloat = leftInset
        var y: CGFloat = initialOffsetY

        weekViews.enumerated().forEach { index, week in
            switch viewType {
            case .month:
                week.frame = CGRect(
                    x: leftInset,
                    y: y,
                    width: weekViewWidth,
                    height: self.weekHeight
                )
                y = week.frame.maxY
                
            case .week:
                let width = self.superviewWidth - (leftInset + rightInset)

                week.frame = CGRect(
                    x: x,
                    y: initialOffsetY,
                    width: width,
                    height: self.weekHeight
                )
                x = week.frame.maxX + (leftInset + rightInset)
            }
            week.setupDays()
        }
    }
    
    private func setupMonthLabel() {
        let textColor = month.isCurrent ? monthViewAppearanceDelegate?.verticalCurrentMonthTitleColor?() :
            monthViewAppearanceDelegate?.verticalMonthTitleColor?()
				let textFormatter = monthViewAppearanceDelegate?.verticalMonthDateFormater?() ?? VAFormatters.monthFormatter
        
        monthLabel = UILabel()
        monthLabel?.text = textFormatter.string(from: month.date)
        monthLabel?.textColor = textColor ?? monthLabel?.textColor
        monthLabel?.font = monthViewAppearanceDelegate?.verticalMonthTitleFont?() ?? monthLabel?.font
        monthLabel?.sizeToFit()
        monthLabel?.center.x = center.x
        addSubview(monthLabel ?? UIView())
    }
    
}

extension VAMonthView: VAWeekViewDelegate {
    
    func dayStateChanged(_ day: VADay, in week: VAWeek) {
        delegate?.dayStateChanged(day, in: month)
    }
    
}
