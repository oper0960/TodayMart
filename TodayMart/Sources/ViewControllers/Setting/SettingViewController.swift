//
//  SettingViewController.swift
//  ClosedMart
//
//  Created by Gilwan Ryu on 2018. 7. 2..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit
import MessageUI

class SettingViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    let menuArray: [String] = [
        "개선 및 건의사항",
        "오픈소스 라이센스",
        "버전 \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)"
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Custom Method
extension SettingViewController {
    func setup() {
        
        let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Close"), style: .plain, target: self, action: #selector(close(_:)))
        closeButton.tintColor = .black
        navigationItem.rightBarButtonItem = closeButton
        
        self.mainTableView.register(UINib(nibName: "SettingTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingCell")
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.mainTableView.tableFooterView = UIView()
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(["oper0960@gmail.com"])
        return mailVC
    }
    
    @objc func close (_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - MFMailComposeViewController Delegate
extension SettingViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let error = error {
            print(error)
        } else {
            switch result {
            case .sent:
                let alert = UIAlertController(title: "전송 완료", message: "소중한 의견 감사합니다.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                    controller.dismiss(animated: true, completion: nil)
                }
                alert.addAction(okAction)
                controller.present(alert, animated: true, completion: nil)
            case .failed:
                let alert = UIAlertController(title: "전송 실패", message: "잠시 후에 다시 보내주세요.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                    controller.dismiss(animated: true, completion: nil)
                }
                alert.addAction(okAction)
                controller.present(alert, animated: true, completion: nil)
            case .cancelled, .saved:
                controller.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: - UITableView Delegate, Datasource
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingTableViewCell
        
        cell.titleLabel.text = menuArray[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let mailVC = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailVC, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "메일 계정 등록 필요", message: "메일 앱에 계정을 등록해 주세요.", preferredStyle: .alert)
                let goMailAppAction = UIAlertAction(title: "메일 앱 실행", style: .default) { (action) in
                    guard let url = URL(string: "mailto:") else { return }
                    
                    if UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }                                }
                let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
                alert.addAction(goMailAppAction)
                alert.addAction(cancelAction)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        case 1:
            let open = OpenSourceViewController()
            open.opensourceList = [
                OpenSource("SnapKit", license: .mit(year: "2011", name: "SnapKit Team")),
                OpenSource("Floaty", license: .mit(year: "2015", name: "Lee Sun-Hyoup")),
                OpenSource("PanModal", license: .mit(year: "2018", name: "Tiny Speck")),
                OpenSource("GoogleMaps", license: .apache2),
                OpenSource("GooglePlaces", license: .apache2),
                OpenSource("Firebase", license: .apache2)
            ]
            navigationController?.pushViewController(open, animated: true)
        default:
            break
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
