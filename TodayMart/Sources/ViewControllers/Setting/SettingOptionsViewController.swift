//
//  SettingOptionsViewController.swift
//  TodayMart
//
//  Created by Gilwan Ryu on 22/04/2019.
//  Copyright © 2019 Ry. All rights reserved.
//

import UIKit

class SettingOptionsViewController: UIViewController {
    
    enum OptionMenu {
        case rendererAnimation
    }
    
    var menuArray: [OptionMenu] = {
        var array = [OptionMenu]()
        array.append(.rendererAnimation)
        return array
    }()

    @IBOutlet weak var mainTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Custom Method
extension SettingOptionsViewController {
    func setup() {
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.tableFooterView = UIView()
    }
}

// MARK: - UITableView Delegate, Datasource
extension SettingOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath) as! OptionTableViewCell
        switch menuArray[indexPath.row] {
        case .rendererAnimation:
            cell.titleLabel.text = "Cluster Animation"
            cell.optionSwitch.setOn(userDefault.bool(forKey: UserSettings.clusterRendererAnimation), animated: true)
            cell.menu = .rendererAnimation
        }
        cell.selectionStyle = .none
        return cell
    }
}

