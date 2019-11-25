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
    @IBOutlet weak var noneView: UIView!
    
    var favoriteMarts = [Mart]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        getFavorite()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension FavoriteViewController {
    
    func setup() {
        let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Close"), style: .plain, target: self, action: #selector(close(_:)))
        closeButton.tintColor = .black
        navigationItem.rightBarButtonItem = closeButton
        
        mainTableView.register(UINib(nibName: "FavoriteTableViewCell", bundle: nil), forCellReuseIdentifier: "FavoriteCell")
        mainTableView.register(UINib(nibName: "AdMobBannerTableViewCell", bundle: nil), forCellReuseIdentifier: "AdMobCell")
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.tableFooterView = UIView()
    }
    
    @objc func close (_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteMarts.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row != favoriteMarts.count else {
            return 100
        }
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row != favoriteMarts.count else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdMobCell", for: indexPath) as! AdMobBannerTableViewCell
            cell.bannerView.rootViewController = self
            cell.adMobUnitId = AppDelegate.adMobKey_Favorite
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteTableViewCell
//        let mart = favoriteMarts[indexPath.row]
//
//        // 이름
//        cell.placeName.text = mart.name
//
//        // 휴무정보
//        cell.offDay.text = closedDayDescription(week: mart.closedWeek, day: mart.closedDay,
//                                                fixedDay: mart.fixedClosedDay)
//
//        // 영업시간
//        cell.workTime.text = mart.openingHours
//
//        // 영업정보
//        if self.closedDayYN(week: mart.closedWeek, day: mart.closedDay) {
//            cell.status.textColor = .red
//            cell.status.text = "휴무"
//        } else {
//            if mart.closedWeek[0] == 0 && mart.closedDay[0] == 8 || mart.closedWeek[1] == 0 && mart.closedDay[1] == 8 {
//                cell.status.text = "영업정보없음"
//            } else {
//                if openTime(time: mart.openingHours) {
//                    cell.status.text = "영업중"
//                    cell.status.textColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
//                } else {
//                    cell.status.text = "영업종료"
//                    cell.status.textColor = .gray
//                }
//            }
//        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard indexPath.row != favoriteMarts.count else {
            return nil
        }
        let delete = UITableViewRowAction(style: .default, title: "삭제") { (action, indexPath) in
//            let mart = self.favoriteMarts[indexPath.row]
//            do {
//                let db = try SQLiteManager()
//                try db.favoriteExecute(name: mart.name, favorite: 0, doneHandler: {
//                    self.getFavorite()
//                })
//            } catch {
//                self.dbOpenErrorAlert()
//            }
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != favoriteMarts.count else {
            return
        }
        let mart = self.favoriteMarts[indexPath.row]
//        do {
//            let db = try SQLiteManager()
//
//            try db.executeSelect(name: mart.name) {(mart: Mart) in
//                let storyboard = UIStoryboard.init(name: "NearbyMartMap", bundle: nil)
//                let infoViewController = storyboard.instantiateViewController(withIdentifier: "InfomationViewController") as! InfomationViewController
//                infoViewController.title = "마트"
//                infoViewController.mart = mart
//                infoViewController.delegate = self
//                self.presentPanModal(infoViewController)
//            }
//        } catch {
//            dbOpenErrorAlert()
//        }
    }
}

extension FavoriteViewController: InfomationDelegate {
    func completeDismiss() {
        getFavorite()
    }
}

extension FavoriteViewController {
    func getFavorite() {
//        do {
//            self.favoriteMarts.removeAll()
//            let db = try SQLiteManager()
//            try db.getFavoriteExecute { (marts: [Mart]) in
//                self.favoriteMarts = marts
//            }
//            
//            if favoriteMarts.count == 0 {
//                mainTableView.isHidden = true
//                noneView.isHidden = false
//            } else {
//                mainTableView.isHidden = false
//                mainTableView.reloadData()
//                noneView.isHidden = true
//            }
//        } catch {
//            self.dbOpenErrorAlert()
//        }
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


