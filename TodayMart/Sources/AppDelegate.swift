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
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private let googleMapAPIKey: String = "AIzaSyDZnYwGW3IATa45-cfdTViLNd2ZyP9XDxw"
    static let kakaoAPIKEY: String = "KakaoAK c2d8a5dd337febf258ad56b202b55c9a"
    
    // AdMob
    static let adMobKeyTest: String = "ca-app-pub-3940256099942544/2934735716"
    #if DEBUG
    static let adMobKey_Favorite: String = adMobKeyTest
    static let adMobKey_Setting: String = adMobKeyTest
    static let adMobKey_MapView: String = adMobKeyTest
    static let adMobKey_MartInfoView: String = adMobKeyTest
    #else
    static let adMobKey_Favorite: String = "ca-app-pub-9335296893721653/6964742992"
    static let adMobKey_Setting: String = "ca-app-pub-9335296893721653/1641872358"
    static let adMobKey_MapView: String = "ca-app-pub-9335296893721653/9295025304"
    static let adMobKey_MartInfoView: String = "ca-app-pub-9335296893721653/9559405728"
    #endif

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // firebase
        FirebaseApp.configure()
        // googlemaps
        GMSServices.provideAPIKey(self.googleMapAPIKey)
        // admob
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        //userdefault
        setUserDefault()
        
        return true
    }
    
    func setUserDefault() {
        if userDefault.object(forKey: UserSettings.clusterRendererAnimation) == nil {
            userDefault.set(true, forKey: UserSettings.clusterRendererAnimation)
        }
    }
}

