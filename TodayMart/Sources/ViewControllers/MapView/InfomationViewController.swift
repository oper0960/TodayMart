//
//  InfomationViewController.swift
//  TodayMart
//
//  Created by Gilwan Ryu on 15/04/2019.
//  Copyright © 2019 Ry. All rights reserved.
//

import UIKit
import PanModal

protocol InfomationDelegate: class {
    func completeDismiss(marker: GMSMarker, favorite: Int)
}

class InfomationViewController: UIViewController {
    
    
    enum Infomation {
        case closeWeek, closeCurrent, openHours, address, telNumber
    }
    
    var menuArray: [Infomation] = {
        var menu = [Infomation]()
        menu = [.closeWeek, .closeCurrent, .openHours, .address, .telNumber]
        return menu
    }()
    
    @IBOutlet weak var infomationTableView: UITableView!
    @IBOutlet weak var martNameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var mart: Mart?
    var marker: GMSMarker?
    weak var delegate: InfomationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mart = mart else { return }
        
        martNameLabel.text = mart.name
        
        if let _ = marker {
            // 즐겨찾기
            if mart.favorite == 0 {
                favoriteButton.setImage(#imageLiteral(resourceName: "FavoriteIcon"), for: .normal)
            } else {
                favoriteButton.setImage(#imageLiteral(resourceName: "FavoriteIconSelect"), for: .normal)
            }
        } else {
            favoriteButton.isHidden = true
        }
        
        infomationTableView.delegate = self
        infomationTableView.dataSource = self
        infomationTableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let marker = marker, let mart = mart {
            delegate?.completeDismiss(marker: marker, favorite: mart.favorite)
        }
    }
}

// MARK: - Button
extension InfomationViewController {
    @IBAction func favoriteButton(_ sender: UIButton) {
        if let mart = mart {
            let name = mart.name
            var martData: Mart?
            do {
                let db = try SQLiteManager()
                
                try db.executeSelect(name: name) { (mart: Mart) in
                    martData = mart
                }
                
                let updateDB = try SQLiteManager()
                guard let data = martData else { return }
                do {
                    if data.favorite == 0 {
                        try updateDB.favoriteExecute(name: name, favorite: 1, doneHandler: {
                            sender.setImage(#imageLiteral(resourceName: "FavoriteIconSelect"), for: .normal)
                            mart.favorite = 1
                        })
                    } else {
                        try updateDB.favoriteExecute(name: name, favorite: 0, doneHandler: {
                            sender.setImage(#imageLiteral(resourceName: "FavoriteIcon"), for: .normal)
                            mart.favorite = 0
                        })
                    }
                } catch {
                    dbOpenErrorAlert()
                }
            } catch {
                dbOpenErrorAlert()
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension InfomationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! MarkerInfoTableViewCell
        
        guard let mart = mart else { return cell }
        
        switch menuArray[indexPath.row] {
        case .closeWeek:
            cell.descriptionTitleLabel.text = "휴무일"
            cell.descriptionLabel.text = closedDayDescription(week: mart.closedWeek, day: mart.closedDay, fixedDay: mart.fixedClosedDay)
            return cell
        case .closeCurrent:
            cell.descriptionTitleLabel.text = "영업유무"
            if closedDayYN(week: mart.closedWeek, day: mart.closedDay) {
                cell.descriptionLabel.textColor = .red
                cell.descriptionLabel.text = "휴무"
            } else {
                if mart.closedWeek[0] == 0 && mart.closedDay[0] == 8 ||
                    mart.closedWeek[1] == 0 && mart.closedDay[1] == 8 {
                    cell.descriptionLabel.text = "영업정보없음"
                } else {
                    cell.descriptionLabel.textColor = openTime(time: mart.openingHours) ? #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    cell.descriptionLabel.text = openTime(time: mart.openingHours) ? "영업중" : "영업종료"
                }
            }
            return cell
        case .openHours:
            cell.descriptionTitleLabel.text = "영업시간"
            cell.descriptionLabel.text = mart.openingHours
            return cell
        case .address:
            cell.descriptionTitleLabel.text = "주소"
            cell.descriptionLabel.text = mart.address
            return cell
        case .telNumber:
            cell.descriptionTitleLabel.text = "전화번호"
            cell.descriptionLabel.text = mart.telNumber
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if menuArray[indexPath.row] == .telNumber {
            if let tel = mart?.telNumber, let url = URL(string: "tel://\(tel)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

// MARK: - PanModalPresentable
extension InfomationViewController: PanModalPresentable {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var panScrollable: UIScrollView? {
        return infomationTableView
    }
    
    var anchorModalToLongForm: Bool {
        return false
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(300)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(100)
    }
}

// MARK: - Database
extension InfomationViewController {
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
