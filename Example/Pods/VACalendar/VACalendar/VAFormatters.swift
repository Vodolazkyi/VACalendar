//
//  VAFormatters.swift
//  VACalendar
//
//  Created by Anton Vodolazkyi on 26.02.18.
//  Copyright © 2018 Vodolazkyi. All rights reserved.
//

import Foundation

struct VAFormatters {
    
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter
    }()
    
}
