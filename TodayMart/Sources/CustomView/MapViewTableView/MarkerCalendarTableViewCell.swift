//
//  MarkerCalendarTableViewCell.swift
//  TodayMart
//
//  Created by Gilwan Ryu on 2020/01/09.
//  Copyright © 2020 Ry. All rights reserved.
//

import UIKit

class MarkerCalendarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var calendarView: FSCalendar!
    
    var mart: Mart? {
        didSet {
            calendarView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.scrollDirection = .vertical
    }
    
    func closeDayBind(mart: Mart) {
        
        self.mart = mart
        
        guard let mart = self.mart, mart.splitClosedWeek.count == 2, mart.splitClosedDay.count == 2 else {
            return
        }
        
        let week = mart.splitClosedWeek
        let day = mart.splitClosedDay
        let fixedDay = mart.splitFixedClosedDay
        
        let date = Date()
        let calendar = Calendar.current
        
        if week[0] == 0, day[0] == 8 {
            if week[1] == 0, day[1] == 8 {
                if fixedDay.count > 0 {
                    calendarView.select(calculateFixedDay(date: date, calendar: calendar, fixedDay: fixedDay[0]))
                    calendarView.select(calculateFixedDay(date: date, calendar: calendar, fixedDay: fixedDay[1]))
                }
            } else {
                calendarView.select(calculateFixedDay(date: date, calendar: calendar, fixedDay: fixedDay[0]))
                calendarView.select(calculateComponents(calendar: calendar, weekDay: day[1], weekOfMonth: week[1]).date)
            }
        } else {
            if week[1] == 0, day[1] == 8 {
                calendarView.select(calculateComponents(calendar: calendar, weekDay: day[0], weekOfMonth: week[0]).date)
                calendarView.select(calculateFixedDay(date: date, calendar: calendar, fixedDay: fixedDay[1]))
            } else {
                calendarView.select(calculateComponents(calendar: calendar, weekDay: day[0], weekOfMonth: week[0]).date)
                calendarView.select(calculateComponents(calendar: calendar, weekDay: day[1], weekOfMonth: week[1]).date)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension MarkerCalendarTableViewCell {
    
    func calculateFixedDay(date: Date, calendar: Calendar, fixedDay: Int) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        let components = calendar.dateComponents([.year, .month], from: date)
        return dateFormatter.date(from: "\(components.year!)-\(components.month!)-\(fixedDay)")
    }
    
    func calculateComponents(calendar: Calendar, weekDay: Int, weekOfMonth: Int) -> DateComponents {
        let date = Date()
        let calendar = calendar
        
        var dateComponents = DateComponents()
        dateComponents.calendar = calendar
        dateComponents.year = calendar.component(.year, from: date)
        dateComponents.month = calendar.component(.month, from: date)
        dateComponents.weekday = weekDay
        dateComponents.weekOfMonth = weekOfMonth
        
        return dateComponents
    }
}

extension MarkerCalendarTableViewCell: FSCalendarDelegate, FSCalendarDataSource {

    // Today 표시
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        let calendarToday = dateFormatter.string(from: date)
        let dateToday = dateFormatter.string(from: Date())
        
        return calendarToday == dateToday ? "Today" : nil
    }
}

