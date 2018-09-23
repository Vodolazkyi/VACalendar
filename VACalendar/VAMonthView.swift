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
}

class VAMonthView: UIView {
    
    var numberOfWeeks: Int {
        return month.numberOfWeeks
    }
    
    var isDrawn: Bool {
        return !weekViews.isEmpty
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
    var monthLabel: UILabel?
    var weekViews = [VAWeekView]()
    let weekHeight: CGFloat

    private let showDaysOut: Bool
    
    init(month: VAMonth, showDaysOut: Bool, weekHeight: CGFloat) {
        self.month = month
        self.showDaysOut = showDaysOut
        self.weekHeight = weekHeight
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWeeksView(with period: VAPeriodType, shouldShowMonthLabel: Bool) {
        guard isDrawn == false else { return }
        
        if shouldShowMonthLabel {
            setupMonthLabel()
        }

        self.weekViews = []

        month.weeks.enumerated().forEach { index, week in
            let weekView = VAWeekView(week: week, showDaysOut: showDaysOut)
            weekView.delegate = self
            self.weekViews.append(weekView)
            self.addSubview(weekView)
        }
        
        draw(for: period)
    }
    
    func clean() {
        monthLabel = nil
        weekViews = []
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    func week(with date: Date) -> VAWeekView? {
        return weekViews.first(where: { $0.contains(date: date) })
    }

    private func draw(for period: VAPeriodType) {
        period.drawWeeks(in: self)
    }
    
    private func setupMonthLabel() {
        let textColor = month.isCurrent ? monthViewAppearanceDelegate?.verticalCurrentMonthTitleColor?() :
            monthViewAppearanceDelegate?.verticalMonthTitleColor?()
        
        monthLabel = UILabel()
        monthLabel?.text = VAFormatters.monthFormatter.string(from: month.date)
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
