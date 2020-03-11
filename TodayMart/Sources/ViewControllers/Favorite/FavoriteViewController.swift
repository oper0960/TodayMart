//
//  FavoriteViewController.swift
//  ClosedMart
//
//  Created by Gilwan Ryu on 2018. 10. 16..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit
import SwiftyJSON

class FavoriteViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var noneView: UIView!
    
    var favoriteMarts = [Mart]() {
        didSet {
            mainTableView.isHidden = favoriteMarts.count == 0
            noneView.isHidden = favoriteMarts.count != 0
            mainTableView.reloadData()
        }
    }
    
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
            return 200
        }
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row != favoriteMarts.count else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdMobCell", for: indexPath) as! AdMobBannerTableViewCell
            cell.bannerView.rootViewController = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteTableViewCell
        let mart = favoriteMarts[indexPath.row]

        // 이름
        cell.placeName.text = mart.name

        // 휴무정보
        cell.offDay.text = closedDayDescription(week: mart.splitClosedWeek, day: mart.splitClosedDay,
                                                fixedDay: mart.splitFixedClosedDay)

        // 영업시간
        cell.workTime.text = mart.openingHours

        // 영업정보
        if self.closedDayYN(week: mart.splitClosedWeek, day: mart.splitClosedDay) {
            cell.status.textColor = .red
            cell.status.text = "휴무"
        } else {
            if mart.splitClosedWeek[0] == 0 && mart.splitClosedDay[0] == 8 || mart.splitClosedWeek[1] == 0 && mart.splitClosedDay[1] == 8 {
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
        guard indexPath.row != favoriteMarts.count else {
            return nil
        }
        let delete = UITableViewRowAction(style: .default, title: "삭제") { (action, indexPath) in
            self.deleteFavorite(martId: self.favoriteMarts[indexPath.row].id) { result in
                if !result {
                    self.getFavorite()
                }
            }
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != favoriteMarts.count else {
            return
        }
        let mart = self.favoriteMarts[indexPath.row]
        
        let storyboard = UIStoryboard.init(name: "NearbyMartMap", bundle: nil)
        let infoViewController = storyboard.instantiateViewController(withIdentifier: "InfomationViewController") as! InfomationViewController
        infoViewController.title = "마트"
        infoViewController.mart = mart
        infoViewController.delegate = self
        self.presentPanModal(infoViewController)
    }
}

extension FavoriteViewController: InfomationDelegate {
    func completeDismiss() {
        getFavorite()
    }
}

// MARK: - Alamofire
extension FavoriteViewController {
    func getFavorite() {
        NetworkManager.request(method: .get, reqURL: "\(Api.Favorite.getAll)/\(User.current.uuid)", parameters: [:], headers: [:], failed: { error in
            print("favorite Error",error)
        }) { data in
            let decoder = JSONDecoder()
            if let marts = try? decoder.decode([Mart].self, from: data) {
                self.favoriteMarts = marts
            } else {
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
    }
    
    func deleteFavorite(martId: Int, complete: @escaping (Bool) -> ()) {

        var parameters = DictionaryType()
        parameters.updateValue(martId.description, forKey: "martId")
        parameters.updateValue(User.current.uuid, forKey: "userId")

        NetworkManager.request(method: .post, reqURL: Api.Favorite.current, parameters: parameters, headers: [:], failed: { error in
            print("currentFavorite Error",error)
        }) { data in
            let json = JSON(data)
            print(json)
            complete(json["favorite"].boolValue)
        }
    }
}


