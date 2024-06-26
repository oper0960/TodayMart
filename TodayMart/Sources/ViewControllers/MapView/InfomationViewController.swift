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
        case closeWeek, closeCurrent, openHours, address, telNumber, calendar, admob
    }
    
    var menuArray: [Infomation] = {
        var menu = [Infomation]()
        menu = [.closeWeek, .closeCurrent, .openHours, .address, .telNumber, .admob, .calendar]
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
        return menuArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch menuArray[indexPath.row] {
        case .calendar:
            return 300
        case .admob:
            return 200
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let mart = mart else { return UITableViewCell() }

        switch menuArray[indexPath.row] {
        case .closeWeek:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! MarkerInfoTableViewCell
            cell.descriptionTitleLabel.text = "휴무일"
            cell.descriptionLabel.text = closedDayDescription(week: mart.splitClosedWeek, day: mart.splitClosedDay, fixedDay: mart.splitFixedClosedDay)
            return cell
        case .closeCurrent:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! MarkerInfoTableViewCell
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! MarkerInfoTableViewCell
            cell.descriptionTitleLabel.text = "영업시간"
            cell.descriptionLabel.text = mart.openingHours
            return cell
        case .address:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! MarkerInfoTableViewCell
            cell.descriptionTitleLabel.text = "주소 (앱 연결)"
            cell.descriptionLabel.text = mart.address
            return cell
        case .telNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! MarkerInfoTableViewCell
            cell.descriptionTitleLabel.text = "전화번호 (전화걸기)"
            cell.descriptionLabel.text = mart.telNumber
            return cell
        case .calendar:
            let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath) as! MarkerCalendarTableViewCell
            cell.closeDayBind(mart: mart)
            return cell   
        case .admob:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdMobCell", for: indexPath) as! AdMobBannerTableViewCell
            cell.bannerView.rootViewController = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if menuArray[indexPath.row] == .address {
            guard let name = mart?.name, let lat = mart?.latitude, let long = mart?.longitude else { return }
            
            let alert = UIAlertController(title: "내비게이션 앱 선택", message: "앱이 설치되어 있지 않다면 설치페이지로 이동합니다.\n도착지는 주차장입구와는 차이가 있을 수 있습니다.", preferredStyle: .actionSheet)
            let kakao = UIAlertAction(title: "카카오맵", style: .default) { action in
                UIApplication.shared.open(SchemeManager.getUrl(type: .kakaoMap, name: name, long: long, lat: lat), options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
            let naver = UIAlertAction(title: "네이버지도", style: .default) { action in
                UIApplication.shared.open(SchemeManager.getUrl(type: .naverMap, name: name, long: long, lat: lat), options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
            let tmap = UIAlertAction(title: "티맵", style: .default) { action in
                UIApplication.shared.open(SchemeManager.getUrl(type: .tMap, name: name, long: long, lat: lat), options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(kakao)
            alert.addAction(naver)
            alert.addAction(tmap)
            alert.addAction(cancel)
            
            present(alert, animated: true, completion: nil)
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
        return .maxHeightWithTopInset(0)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(0)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
