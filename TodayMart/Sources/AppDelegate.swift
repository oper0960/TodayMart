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
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private let googleMapAPIKey: String = "AIzaSyDZnYwGW3IATa45-cfdTViLNd2ZyP9XDxw"
    static let kakaoAPIKEY: String = "KakaoAK c2d8a5dd337febf258ad56b202b55c9a"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // firebase
        FirebaseApp.configure()
        // googlemaps
        GMSServices.provideAPIKey(self.googleMapAPIKey)
        // admob
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        //userdefault
        setUserDefault()
        
        login()
        
        return true
    }
    
    func setUserDefault() {
        if userDefault.object(forKey: UserSettings.clusterRendererAnimation) == nil {
            userDefault.set(true, forKey: UserSettings.clusterRendererAnimation)
        }
    }
}

extension AppDelegate {
    func login() {
        Keychain.current.synchronizable = true
        
        guard let keychainUUID = Keychain.current.get(KeychainKey.uuid) else {
            if let uuid = UIDevice.current.deviceUUID {
                Keychain.current.set(uuid, forKey: KeychainKey.uuid)
                
                let loginParamater = ["userId": uuid]
                
                NetworkManager.request(method: .post, reqURL: Api.User.login, parameters: loginParamater, headers: [:], failed: { error in
                    print("Login Error",error)
                }) { data in
                    print("login Success")
                    User.current.uuid = uuid
                }
            }
            return
        }
        User.current.uuid = keychainUUID
    }
}
