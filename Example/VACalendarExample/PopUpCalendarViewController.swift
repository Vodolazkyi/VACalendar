//
//  PopUpCalendarViewController.swift
//  VACalendarExample
//
//  Created by Anton Vodolazkyi on 23.03.18.
//  Copyright © 2018 Anton Vodolazkyi. All rights reserved.
//

import UIKit

class PopUpCalendarViewController: UIViewController {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var showCalendarButton: UIButton!
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E dd LLLL"
        return formatter
    }()
    
    private lazy var calendarPopup: CalendarPopUpView = {
        let frame = CGRect(
            x: 15,
            y: dayLabel.frame.maxY + 20,
            width: view.frame.width - 30,
            height: 365
        )
        let calendar = CalendarPopUpView(frame: frame)
        calendar.backgroundColor = .clear
        calendar.layer.shadowColor = UIColor.black.cgColor
        calendar.layer.shadowOpacity = 0.4
        calendar.layer.shadowOffset = .zero
        calendar.layer.shadowRadius = 5
        calendar.didSelectDay = { [weak self] date in
            self?.setSelectedDate(date)
        }

        return calendar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(
            red: 240 / 255,
            green: 240 / 255,
            blue: 240 / 255,
            alpha: 1.0
        )
        setSelectedDate(Date())
    }

    @IBAction func didTapSelectDay(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            view.addSubview(calendarPopup)
        } else {
            calendarPopup.removeFromSuperview()
        }
    }
    
    private func setSelectedDate(_ date: Date) {
        dayLabel.text = formatter.string(from: date)
    }
    
}
