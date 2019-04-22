//
//  AppDelegate.swift
//  ClosedMart
//
//  Created by seoju on 2018. 6. 8..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let googleMapAPIKey: String = "AIzaSyDZnYwGW3IATa45-cfdTViLNd2ZyP9XDxw"
    static let kakaoAPIKEY: String = "KakaoAK c2d8a5dd337febf258ad56b202b55c9a"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        GMSServices.provideAPIKey(self.googleMapAPIKey)
        
        setUserDefault()
        
        return true
    }
    
    func setUserDefault() {
        if userDefault.object(forKey: UserSettings.clusterRendererAnimation) == nil {
            userDefault.set(true, forKey: UserSettings.clusterRendererAnimation)
        }
    }
}

