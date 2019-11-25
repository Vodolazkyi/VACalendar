//
//  HorizontalCalendarController.swift
//  VACalendarExample
//
//  Created by Anton Vodolazkyi on 09.03.18.
//  Copyright © 2018 Anton Vodolazkyi. All rights reserved.
//

import UIKit
import VACalendar

final class HorizontalCalendarController: UIViewController {
    @IBOutlet var monthHeaderView: VAMonthHeaderView! {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "LLLL"

            let appereance = VAMonthHeaderViewAppearance(
                previousButtonImage: #imageLiteral(resourceName: "previous"),
                nextButtonImage: #imageLiteral(resourceName: "next"),
                dateFormatter: dateFormatter
            )
            monthHeaderView.delegate = self
            monthHeaderView.appearance = appereance
        }
    }

    @IBOutlet var weekDaysView: VAWeekDaysView! {
        didSet {
            let appereance = VAWeekDaysViewAppearance(symbolsType: .veryShort, calendar: defaultCalendar)
            weekDaysView.appearance = appereance
        }
    }

    let defaultCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    @IBOutlet var calendarView: VACalendarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.calendar = VACalendar(calendar: defaultCalendar)
        calendarView.showDaysOut = true
        calendarView.selectionStyle = .multi
        calendarView.monthDelegate = monthHeaderView
        calendarView.dayViewAppearanceDelegate = self
        calendarView.monthViewAppearanceDelegate = self
        calendarView.calendarDelegate = self
        calendarView.scrollDirection = .horizontal
        let last = defaultCalendar.date(byAdding: .year, value: 1, to: Date())!
        calendarView.setAvailableDates(.range(Date(), last))
        calendarView.setSupplementaries([
            (Date().addingTimeInterval(-(60 * 60 * 70)), [VADaySupplementary.bottomDots([.red, .magenta])]),
            (Date().addingTimeInterval(60 * 60 * 110), [VADaySupplementary.bottomDots([.red])]),
            (Date().addingTimeInterval(60 * 60 * 370), [VADaySupplementary.bottomDots([.blue, .darkGray])]),
            (Date().addingTimeInterval(60 * 60 * 430), [VADaySupplementary.bottomDots([.orange, .purple, .cyan])])
        ])
        calendarView.setup()
    }

    @IBAction func changeMode(_ sender: Any) {
        calendarView.changeViewType()
    }
}

extension HorizontalCalendarController: VAMonthHeaderViewDelegate {
    func didTapNextMonth() {
        calendarView.nextMonth()
    }

    func didTapPreviousMonth() {
        calendarView.previousMonth()
    }
}

extension HorizontalCalendarController: VAMonthViewAppearanceDelegate {
    func leftInset() -> CGFloat {
        return 10.0
    }

    func rightInset() -> CGFloat {
        return 10.0
    }

    func verticalMonthTitleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .semibold)
    }

    func verticalMonthTitleColor() -> UIColor {
        return .black
    }

    func verticalCurrentMonthTitleColor() -> UIColor {
        return .red
    }
}

extension HorizontalCalendarController: VADayViewAppearanceDelegate {
    func textColor(for state: VADayState) -> UIColor {
        switch state {
        case .out:
            return UIColor(red: 214 / 255, green: 214 / 255, blue: 219 / 255, alpha: 1.0)
        case .selected:
            return .white
        case .unavailable:
            return .lightGray
        default:
            return .black
        }
    }

    func textBackgroundColor(for state: VADayState) -> UIColor {
        switch state {
        case .selected:
            return .red
        default:
            return .clear
        }
    }

    func shape() -> VADayShape {
        return .circle
    }

    func dotBottomVerticalOffset(for state: VADayState) -> CGFloat {
        switch state {
        case .selected:
            return 2
        default:
            return -7
        }
    }
}

extension HorizontalCalendarController: VACalendarViewDelegate {
    func selectedDates(_ dates: [Date]) {
        calendarView.startDate = dates.last ?? Date()
        print(dates)
    }
}
