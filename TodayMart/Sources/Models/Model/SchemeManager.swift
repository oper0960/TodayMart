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
    
    static func getUrl(type: SchemeManager, long: Double, lat: Double) -> URL {
        switch type {
        case .kakaoMap:
            guard let currentLat = Locations.shared.currentLocation?.coordinate.latitude, let currentLong = Locations.shared.currentLocation?.coordinate.longitude else {
                return URL(string: "kakaomap://look?p=\(lat),\(long)")!
            }
            return URL(string: "kakaomap://route?sp=\(currentLat),\(currentLong)&ep=\(lat),\(long)&by=CAR")!
        case .naverMap:
            return URL(string: "nmap://map?lat=\(lat)&lng=\(long)&level=13&mode=3&traffic=false&appname=com.ryu.todaymart")!
        case .tMap:
            return URL(string: "tmap://?rGoX=\(long)&rGoY=\(lat)")!
        }
    }
}
