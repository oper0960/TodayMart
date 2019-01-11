//
//  MainViewController.swift
//  ClosedMart
//
//  Created by seoju on 2018. 6. 8..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var martTabBarController: UITabBarController = {
        let tabBarController: UITabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = UIColor(hex32: 0xE95784, alpha: 1.0)
        return tabBarController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        makeTabViewController()
    }
}

// MARK: - Custom method
extension MainViewController {
    
    func makeTabViewController() {
        if let nearbyMartViewController: NearbyMartMapViewController = UIStoryboard(name: "NearbyMartMap", bundle: nil).instantiateInitialViewController() as? NearbyMartMapViewController {
            
            nearbyMartViewController.title = "내주변찾기"
            nearbyMartViewController.tabBarItem = UITabBarItem(title: "내주변찾기", image: #imageLiteral(resourceName: "MapIcon"), tag: 0)
            self.martTabBarController.viewControllers = [nearbyMartViewController].map({ UINavigationController.init(rootViewController: $0) })
        }
        
        if let favoriteViewController: FavoriteViewController = UIStoryboard(name: "Favorite", bundle: nil).instantiateInitialViewController() as? FavoriteViewController {
            
            favoriteViewController.title = "즐겨찾기"
            favoriteViewController.tabBarItem = UITabBarItem(title: "즐겨찾기", image: #imageLiteral(resourceName: "FavoriteIcon"), tag: 1)
            self.martTabBarController.viewControllers?.append(UINavigationController.init(rootViewController: favoriteViewController))
        }
        
        if let settingViewController: SettingViewController = UIStoryboard(name: "Setting", bundle: nil).instantiateInitialViewController() as? SettingViewController {
            
            settingViewController.title = "설정"
            settingViewController.tabBarItem = UITabBarItem(title: "설정", image: #imageLiteral(resourceName: "SettingIcon"), tag: 2)
            self.martTabBarController.viewControllers?.append(UINavigationController.init(rootViewController: settingViewController))
        }
        
        self.view.addSubview(self.martTabBarController.view)
    }
}
