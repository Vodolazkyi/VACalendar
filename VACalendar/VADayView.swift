//
//  VADayView.swift
//  VACalendar
//
//  Created by Anton Vodolazkyi on 20.02.18.
//  Copyright © 2018 Vodolazkyi. All rights reserved.
//

import UIKit

@objc
public protocol VADayViewAppearanceDelegate: class {
    @objc optional func font(for state: VADayState) -> UIFont
    @objc optional func textColor(for state: VADayState) -> UIColor
    @objc optional func textBackgroundColor(for state: VADayState) -> UIColor
    @objc optional func backgroundColor(for state: VADayState) -> UIColor
    @objc optional func borderWidth(for state: VADayState) -> CGFloat
    @objc optional func borderColor(for state: VADayState) -> UIColor
    @objc optional func dotBottomVerticalOffset(for state: VADayState) -> CGFloat
    @objc optional func shape() -> VADayShape
    // percent of the selected area to be painted
    @objc optional func selectedArea() -> CGFloat
}

protocol VADayViewDelegate: class {
    func dayStateChanged(_ day: VADay)
}

class VADayView: UIView {
    
    var day: VADay
    weak var delegate: VADayViewDelegate?
    
    weak var dayViewAppearanceDelegate: VADayViewAppearanceDelegate? {
        return (superview as? VAWeekView)?.dayViewAppearanceDelegate
    }
    
    private var dotStackView: UIStackView {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.spacing = dotSpacing
        return stack
    }
    
    private let dotSpacing: CGFloat = 5
    private let dotSize: CGFloat = 5
    private var supplementaryViews = [UIView]()
    private let dateLabel = UILabel()
    
    init(day: VADay) {
        self.day = day
        super.init(frame: .zero)
        
        self.day.stateChanged = { [weak self] state in
            self?.setState(state)
        }
        
        self.day.supplementariesDidUpdate = { [weak self] in
            self?.updateSupplementaryViews()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSelect))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDay() {
        let shortestSide: CGFloat = (frame.width < frame.height ? frame.width : frame.height)
        let side: CGFloat = shortestSide * (dayViewAppearanceDelegate?.selectedArea?() ?? 0.8)
        
        dateLabel.font = dayViewAppearanceDelegate?.font?(for: day.state) ?? dateLabel.font
        dateLabel.text = VAFormatters.dayFormatter.string(from: day.date)
        dateLabel.textAlignment = .center
        dateLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: side,
            height: side
        )
        dateLabel.center = CGPoint(x: frame.width / 2, y: frame.height / 2)

        setState(day.state)
        addSubview(dateLabel)
        updateSupplementaryViews()
    }
    
    @objc
    private func didTapSelect() {
        guard day.state != .out && day.state != .unavailable else { return }
        delegate?.dayStateChanged(day)
    }
    
    private func setState(_ state: VADayState) {
        if dayViewAppearanceDelegate?.shape?() == .circle && state == .selected {
            dateLabel.clipsToBounds = true
            dateLabel.layer.cornerRadius = dateLabel.frame.height / 2
        }
        
        backgroundColor = dayViewAppearanceDelegate?.backgroundColor?(for: state) ?? backgroundColor
        layer.borderColor = dayViewAppearanceDelegate?.borderColor?(for: state).cgColor ?? layer.borderColor
        layer.borderWidth = dayViewAppearanceDelegate?.borderWidth?(for: state) ?? dateLabel.layer.borderWidth
        
        dateLabel.textColor = dayViewAppearanceDelegate?.textColor?(for: state) ?? dateLabel.textColor
        dateLabel.backgroundColor = dayViewAppearanceDelegate?.textBackgroundColor?(for: state) ?? dateLabel.backgroundColor
        
        updateSupplementaryViews()
    }
    
    private func updateSupplementaryViews() {
        removeAllSupplementaries()
        
        day.supplementaries.forEach { supplementary in
            switch supplementary {
            case .bottomDots(let colors):
                let stack = dotStackView

                colors.forEach { color in
                    let dotView = VADotView(size: dotSize, color: color)
                    stack.addArrangedSubview(dotView)
                }
                let spaceOffset = CGFloat(colors.count - 1) * dotSpacing
                let stackWidth = CGFloat(colors.count) * dotSpacing + spaceOffset
                
                let verticalOffset = dayViewAppearanceDelegate?.dotBottomVerticalOffset?(for: day.state) ?? 2
                stack.frame = CGRect(x: 0, y: dateLabel.frame.maxY + verticalOffset, width: stackWidth, height: dotSize)
                stack.center.x = dateLabel.center.x
                addSubview(stack)
                supplementaryViews.append(stack)
            }
        }
    }
    
    private func removeAllSupplementaries() {
        supplementaryViews.forEach { $0.removeFromSuperview() }
        supplementaryViews = []
    }
    
}
