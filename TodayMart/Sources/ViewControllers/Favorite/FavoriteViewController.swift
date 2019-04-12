//
//  FavoriteViewController.swift
//  ClosedMart
//
//  Created by Gilwan Ryu on 2018. 10. 16..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    var favoriteMarts = [Mart]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
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
        self.mainTableView.tableFooterView = UIView()
    }
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteMarts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellType.mainCell.rawValue, for: indexPath) as! FavoriteTableViewCell
        
        let mart = self.favoriteMarts[indexPath.row]
        
        // 이름
        cell.placeName.text = mart.name
        
        // 휴무정보
        cell.offDay.text = self.closedDayDescription(week: mart.closedWeek, day: mart.closedDay,
                                                     fixedDay: mart.fixedClosedDay)
        
        // 영업시간
        cell.workTime.text = mart.openingHours
        
        // 영업정보
        if self.closedDayYN(week: mart.closedWeek, day: mart.closedDay) {
            cell.status.textColor = .red
            cell.status.text = "휴무"
        } else {
            if mart.closedWeek[0] == 0 && mart.closedDay[0] == 8 || mart.closedWeek[1] == 0 && mart.closedDay[1] == 8 {
                cell.status.text = "영업정보없음"
            } else {
                if openTime(time: mart.openingHours) {
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
            let mart = self.favoriteMarts[indexPath.row]
            do {
                let db = try SQLiteManager()
                try db.favoriteExecute(name: mart.name, favorite: 0, doneHandler: {
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
            self.favoriteMarts.removeAll()
            let db = try SQLiteManager()
            try db.getFavoriteExecute { (marts: [Mart]) in
                self.favoriteMarts = marts
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


