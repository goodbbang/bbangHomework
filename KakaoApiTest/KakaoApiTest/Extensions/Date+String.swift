//
//  Date+String.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/23.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import Foundation

extension Date {
    
    func string(with format: String = "yyyy년 MM월 dd일 a hh:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension Date {
    func dateAgo(with format: String = "yyyy년 MM월 dd일") -> String {

        let calendar = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)!
        let unitFlags : NSCalendar.Unit = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        
        let now = NSDate()
        let earliest = now.earlierDate(self)

        let latest = (earliest == now as Date) ? self : now as Date
        let components:NSDateComponents = calendar.components(unitFlags, from: earliest, to: latest as Date, options: []) as NSDateComponents
    
        switch components.day {
            case 0:
                return "오늘"
            case 1:
                return "어제"
            default:
                return self.string(with: format)
        }
    }
}
