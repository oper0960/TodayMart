//
//  OpenSourceViewController.swift
//  BankQ
//
//  Created by Gilwan Ryu on 11/02/2019.
//  Copyright © 2019 BeyondPlatformService. All rights reserved.
//

import UIKit

class OpenSourceViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    
    var opensourceList = [OpenSource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - setup
extension OpenSourceViewController {
    func setup() {
        title = "오픈소스 라이센스"
        mainTableView.register(UINib(nibName: "OpenSourceTableViewCell", bundle: nil), forCellReuseIdentifier: "source")
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.tableFooterView = UIView()
        
        guard opensourceList.count > 0 else { return }
        mainTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension OpenSourceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return opensourceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "source", for: indexPath) as! OpenSourceTableViewCell
        let opensource = opensourceList[indexPath.row]
        cell.titleLabel.text = opensource.opensourceName
        cell.licenseLabel.text = opensource.license.licenseTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let opensource = opensourceList[indexPath.row]
        let licenseTextViewController = OpenSourceTextViewController()
        licenseTextViewController.opensource = opensource
        navigationController?.pushViewController(licenseTextViewController, back: "뒤로", animated: true)
    }
}
