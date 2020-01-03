//
//  InfomationViewController.swift
//  TodayMart
//
//  Created by Gilwan Ryu on 15/04/2019.
//  Copyright © 2019 Ry. All rights reserved.
//

import UIKit
import PanModal
import GoogleMobileAds
import Firebase
import SwiftyJSON

protocol InfomationDelegate: class {
    func completeDismiss()
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
    weak var delegate: InfomationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.completeDismiss()
    }
}

extension InfomationViewController {
    func setup() {
        guard let mart = mart else { return }
        
        martNameLabel.text = mart.name
        
        // 즐겨찾기
        getCurrentFavorite { result in
            self.favoriteButton.setImage(result ? #imageLiteral(resourceName: "FavoriteIconSelect") : #imageLiteral(resourceName: "FavoriteIcon"), for: .normal)
        }
        
        infomationTableView.register(UINib(nibName: "AdMobBannerTableViewCell", bundle: nil), forCellReuseIdentifier: "AdMobCell")
        infomationTableView.delegate = self
        infomationTableView.dataSource = self
        infomationTableView.tableFooterView = UIView()
    }
}

// MARK: - Button
extension InfomationViewController {
    @IBAction func favoriteButton(_ sender: UIButton) {
        
        setCurrentFavorite { result in
            self.favoriteButton.setImage(result ? #imageLiteral(resourceName: "FavoriteIconSelect") : #imageLiteral(resourceName: "FavoriteIcon"), for: .normal)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension InfomationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row != menuArray.count else {
            return 100
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row != menuArray.count else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdMobCell", for: indexPath) as! AdMobBannerTableViewCell
            cell.bannerView.rootViewController = self
            cell.adMobUnitId = AppDelegate.adMobKey_MartInfoView
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! MarkerInfoTableViewCell
        
        guard let mart = mart else { return cell }

        switch menuArray[indexPath.row] {
        case .closeWeek:
            cell.descriptionTitleLabel.text = "휴무일"
            cell.descriptionLabel.text = closedDayDescription(week: mart.splitClosedWeek, day: mart.splitClosedDay, fixedDay: mart.splitFixedClosedDay)
            return cell
        case .closeCurrent:
            cell.descriptionTitleLabel.text = "영업유무"
            if closedDayYN(week: mart.splitClosedWeek, day: mart.splitClosedDay) {
                cell.descriptionLabel.textColor = .red
                cell.descriptionLabel.text = "휴무"
            } else {
                cell.descriptionLabel.textColor = openTime(time: mart.openingHours) ? #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                cell.descriptionLabel.text = openTime(time: mart.openingHours) ? "영업중" : "영업종료"
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
            cell.descriptionTitleLabel.text = "전화번호 (전화걸기)"
            cell.descriptionLabel.text = mart.telNumber
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != menuArray.count else {
            return
        }
        
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
        return .contentHeight(400)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(100)
    }
}

// MARK: - Alamofire
extension InfomationViewController {
    func getCurrentFavorite(complete: @escaping (Bool) -> ()) {
        
        guard let mart = mart else { return }
        
        NetworkManager.request(method: .get, reqURL: "\(Api.Favorite.current)/\(mart.id.description)/\(User.current.uuid)", parameters: [:], headers: [:], failed: { error in
            print("currentFavorite Error",error)
        }) { data in
            let json = JSON(data)
            complete(json["favorite"].boolValue)
        }
    }
    
    func setCurrentFavorite(complete: @escaping (Bool) -> ()) {
        
        guard let mart = mart else { return }
        
        var parameters = DictionaryType()
        parameters.updateValue(mart.id.description, forKey: "martId")
        parameters.updateValue(User.current.uuid, forKey: "userId")
        
        NetworkManager.request(method: .post, reqURL: Api.Favorite.current, parameters: parameters, headers: [:], failed: { error in
            print("currentFavorite Error",error)
        }) { data in
            let json = JSON(data)
            complete(json["favorite"].boolValue)
        }
    }
}
