//
//  FavoriteViewController.swift
//  ClosedMart
//
//  Created by Ryu on 2018. 10. 16..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    var favoriteMart = [MartTuple]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        self.getFavorite()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
}

extension FavoriteViewController {
    func setup() {
        self.mainTableView.register(UINib(nibName: "FavoriteTableViewCell", bundle: nil), forCellReuseIdentifier: TableViewCellType.mainCell.rawValue)
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        let footer = UIView()
        self.mainTableView.tableFooterView = footer
    }
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteMart.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellType.mainCell.rawValue, for: indexPath) as! FavoriteTableViewCell
        
        let mart = self.favoriteMart[indexPath.row]
        
        // 이름
        cell.placeName.text = mart.0
        
        // 휴무정보
        cell.offDay.text = self.closedDayDescription(week: mart.1, day: mart.2, fixedDay: mart.5)
        
        // 영업시간
        cell.workTime.text = mart.4
        
        // 영업정보
        if self.closedDayYN(week: mart.1, day: mart.2) {
            cell.status.textColor = .red
            cell.status.text = "휴무"
        } else {
            if mart.1[0] == 0 && mart.2[0] == 8 || mart.1[1] == 0 && mart.2[1] == 8 {
                cell.status.text = "영업정보없음"
            } else {
                if self.openTime(time: mart.4) {
                    cell.status.text = "영업중"
                    cell.status.textColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                } else {
                    cell.status.text = "영업종료"
                    cell.status.textColor = .gray
                }
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "삭제") { (action, indexPath) in
            let mart = self.favoriteMart[indexPath.row]
            do {
                let db = try SQLiteManager()
                try db.favoriteExecute(name: mart.0, favorite: 0, doneHandler: {
                    self.getFavorite()
                })
            } catch {
                self.dbOpenErrorAlert()
            }
        }
        return [delete]
    }
}

extension FavoriteViewController {
    func getFavorite() {
        do {
            self.favoriteMart.removeAll()
            let db = try SQLiteManager()
            try db.getFavoriteExecute { (mart: MartTuple) in
                self.favoriteMart.append(mart)
            }
            self.mainTableView.reloadData()
        } catch {
            self.dbOpenErrorAlert()
        }
    }
    
    func dbOpenErrorAlert() {
        let alert = UIAlertController(title: "DB 불러오기 실패", message: "잠시후에 다시 실행해주세요.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        DispatchQueue.main.async {
            if let topController = UIApplication.topViewController() {
                topController.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension FavoriteViewController {
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
        
        if week[0] == 0 && day[0] == 8 {
            if week[1] == 0 && day[1] == 8 {
                return "매달 \(fixedDay[0]),\(fixedDay[1])일"
            } else {
                return "매달 \(fixedDay[0])일, \(week[1])번째주 \(dayToString(day: day[1]))"
            }
        } else {
            if week[1] == 0 && day[1] == 8 {
                return "\(week[0])번째주 \(dayToString(day: day[0])), 매달 \(fixedDay[0])일"
            }
        }
        
        return "\(week[0])번째주 \(dayToString(day: day[0])), \(week[1])번째주 \(dayToString(day: day[1]))"
    }
    
    func closedDayYN (week: closedWeek, day: closedDay) -> Bool {
        
        if week[0] == 0 && day[0] == 8 || week[1] == 0 && day[1] == 8 {
            return false
        }
        
        let time: TimeZone = TimeZone.current
        let today = Date(timeIntervalSinceNow: TimeInterval(time.secondsFromGMT()))
        let calendar = Calendar.current
        
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
}
