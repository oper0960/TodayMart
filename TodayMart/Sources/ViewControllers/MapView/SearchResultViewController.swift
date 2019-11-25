//
//  SearchResultViewController.swift
//  TodayMart
//
//  Created by Gilwan Ryu on 30/04/2019.
//  Copyright © 2019 Ry. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase

protocol SearchResultDelegate: class {
    func focusMart(longitude: String, latitude: String)
}

class SearchResultViewController: UIViewController {
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    weak var delegate: SearchResultDelegate?
    
    var marts = [Mart]() {
        willSet {
            indicator.startAnimating()
        }
        didSet {
            searchTableView.reloadData()
            indicator.stopAnimating()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension SearchResultViewController {
    func setup() {
        searchTableView.register(UINib(nibName: "AdMobBannerTableViewCell", bundle: nil), forCellReuseIdentifier: "AdMobCell")
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdMobCell") as! AdMobBannerTableViewCell
        cell.bannerView.rootViewController = self
        cell.adMobUnitId = AppDelegate.adMobKey_MapView
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resultCell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultTableViewCell
        let mart = marts[indexPath.row]
        resultCell.nameLabel.text = mart.name
        resultCell.pinButton.tag = indexPath.row
        resultCell.pinButton.addTarget(self, action: #selector(goToMart(_:)), for: .touchUpInside)
        return resultCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mart = marts[indexPath.row]
        let storyboard = UIStoryboard.init(name: "NearbyMartMap", bundle: nil)
        let infoViewController = storyboard.instantiateViewController(withIdentifier: "InfomationViewController") as! InfomationViewController
        infoViewController.title = "마트"
        infoViewController.mart = mart
        self.presentPanModal(infoViewController)
    }
    
    @objc func goToMart(_ sender: UIButton) {
//        let mart = marts[sender.tag]
//        delegate?.focusMart(longitude: mart.longitude, latitude: mart.latitude)
    }
}
