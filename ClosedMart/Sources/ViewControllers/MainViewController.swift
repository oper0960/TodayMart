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
        tabBarController.tabBar.tintColor = #colorLiteral(red: 0, green: 0.5803921569, blue: 1, alpha: 1)
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
            nearbyMartViewController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "MapIcon"), tag: 0)
            nearbyMartViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
            self.martTabBarController.viewControllers = [nearbyMartViewController].map({ UINavigationController.init(rootViewController: $0) })
        }
        
        if let favoriteViewController: FavoriteViewController = UIStoryboard(name: "Favorite", bundle: nil).instantiateInitialViewController() as? FavoriteViewController {
            
            favoriteViewController.title = "즐겨찾기"
            favoriteViewController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "FavoriteIcon"), tag: 1)
            favoriteViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
            self.martTabBarController.viewControllers?.append(UINavigationController.init(rootViewController: favoriteViewController))
        }
        
        if let settingViewController: SettingViewController = UIStoryboard(name: "Setting", bundle: nil).instantiateInitialViewController() as? SettingViewController {
            
            settingViewController.title = "설정"
            settingViewController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "SettingIcon"), tag: 2)
            settingViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
            self.martTabBarController.viewControllers?.append(UINavigationController.init(rootViewController: settingViewController))
        }
        
        self.view.addSubview(self.martTabBarController.view)
    }
}
