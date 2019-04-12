//
//  StringExtension.swift
//  TodayMart
//
//  Created by Gilwan Ryu on 12/04/2019.
//  Copyright © 2019 Ry. All rights reserved.
//

import UIKit

extension NSObject {
    func closedDayYN (week: closedWeek, day: closedDay) -> Bool {
        
        if week[0] == 0 && day[0] == 8 || week[1] == 0 && day[1] == 8 {
            return false
        }
        
        let today = Date()
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko-KR")
        
        // 기준점 = 오늘
        var centerDate = DateComponents(calendar: calendar)
        centerDate.month = calendar.component(.month, from: today)
        centerDate.weekday = calendar.component(.weekday, from: today)
        centerDate.weekdayOrdinal = calendar.component(.weekdayOrdinal, from: today)
        
        // 첫번째 휴무
        var firstWeekdate = DateComponents()
        firstWeekdate.month = calendar.component(.month, from: today)
        firstWeekdate.weekday = day[0]
        firstWeekdate.weekdayOrdinal = week[0]
        
        // 두번째 휴무
        var thirdWeekdate = DateComponents()
        thirdWeekdate.month = calendar.component(.month, from: today)
        thirdWeekdate.weekday = day[1]
        thirdWeekdate.weekdayOrdinal = week[1]
        
        if centerDate.weekdayOrdinal == firstWeekdate.weekdayOrdinal && centerDate.weekday == firstWeekdate.weekday {
            return true
        }
        
        if centerDate.weekdayOrdinal == thirdWeekdate.weekdayOrdinal && centerDate.weekday == thirdWeekdate.weekday {
            return true
        }
        return false
    }
    
    func openTime(time: String) -> Bool {
        
        let timeSplit = time.split(separator: "~")
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "HH:mm"
        
        let currentTime = dateFormatter.string(from: date)
        
        guard let startTime = dateFormatter.date(from: String(timeSplit[0])),
            let centerTime = dateFormatter.date(from: currentTime),
            let closeTime = dateFormatter.date(from: String(timeSplit[1])) else { return false }
        
        return startTime < centerTime && centerTime < closeTime
    }
    
    func closedDayDescription(week: closedWeek, day: closedDay, fixedDay: [Int]) -> String {
        
        enum Day: Int {
            case sunday = 1
            case monday = 2
            case tuesday = 3
            case wednesday = 4
            case thursday = 5
            case friday = 6
            case saturday = 7
        }
        
        func dayToString(day: Int) -> String {
            
            switch day {
            case Day.sunday.rawValue:
                return "일요일"
            case Day.monday.rawValue:
                return "월요일"
            case Day.tuesday.rawValue:
                return "화요일"
            case Day.wednesday.rawValue:
                return "수요일"
            case Day.thursday.rawValue:
                return "목요일"
            case Day.friday.rawValue:
                return "금요일"
            default:
                return "토요일"
            }
        }
        
        guard week.count == 2 && day.count == 2 else {
            return "휴무정보없음"
        }
        
        if week[0] == 0, day[0] == 8 {
            if week[1] == 0, day[1] == 8 {
                return fixedDay.count > 0 ? "매달 \(fixedDay[0]),\(fixedDay[1])일" : "연중무휴"
            } else {
                return "매달 \(fixedDay[0])일, \(week[1])번째주 \(dayToString(day: day[1]))"
            }
        } else {
            if week[1] == 0, day[1] == 8 {
                return "\(week[0])번째주 \(dayToString(day: day[0])), 매달 \(fixedDay[0])일"
            }
        }
        
        return "\(week[0])번째주 \(dayToString(day: day[0])), \(week[1])번째주 \(dayToString(day: day[1]))"
    }
}
