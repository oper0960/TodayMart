//
//  SchemeManager.swift
//  TodayMart
//
//  Created by Buxi on 2020/01/03.
//  Copyright © 2020 Ry. All rights reserved.
//

import UIKit

enum SchemeManager {
    case naverMap, kakaoMap, tMap
    
    static func getUrl(type: SchemeManager, name: String, long: Double, lat: Double) -> URL {
        switch type {
        case .kakaoMap:
            
            let url: URL
            
            if let currentLat = Locations.shared.currentLocation?.coordinate.latitude, let currentLong = Locations.shared.currentLocation?.coordinate.longitude {
                url = URL(string: "kakaomap://route?sp=\(currentLat),\(currentLong)&ep=\(lat),\(long)&by=CAR")!
            } else {
                url = URL(string: "kakaomap://look?p=\(lat),\(long)")!
            }
            
            if UIApplication.shared.canOpenURL(url) {
                return url
            } else {
                return URL(string: "https://apps.apple.com/us/app/id304608425")!
            }
            
        case .naverMap:
            
            let url: URL
            
            if let currentLat = Locations.shared.currentLocation?.coordinate.latitude, let currentLong = Locations.shared.currentLocation?.coordinate.longitude {
                url = URL(string: "nmap://route/car?slat=\(currentLat)&slng=\(currentLong)&sname=\("현재위치")&dlat=\(lat)&dlng=\(long)&dname=\(name)&appname=com.ryu.todaymart".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")!
            } else {
                url = URL(string: "nmap://map?lat=\(lat)&lng=\(long)&level=13&mode=1&traffic=false&appname=com.ryu.todaymart")!
            }
            
            if UIApplication.shared.canOpenURL(url) {
                return url
            } else {
                return URL(string: "http://itunes.apple.com/app/id311867728?mt=8")!
            }
            
        case .tMap:
            
            let url: URL
            
            url = URL(string: "tmap://?rGoName=\(name)&rGoX=\(long)&rGoY=\(lat)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")!
            
            if UIApplication.shared.canOpenURL(url) {
                return url
            } else {
                return URL(string: "https://apps.apple.com/kr/app/t-map-for-all/id431589174")!
            }
        }
    }
}
