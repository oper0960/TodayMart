//
//  Mart.swift
//  ClosedMart
//
//  Created by Gilwan Ryu on 2018. 6. 11..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit
import CoreLocation

typealias name = String
typealias closedWeek = [Int]
typealias closedDay = [Int]
typealias fixedClosedDay = [Int]

class Mart {
    var name: String
    var closedWeek: [Int]
    var closedDay: [Int]
    var favorite: Int
    var openingHours: String
    var fixedClosedDay: [Int]
    var address: String
    var telNumber: String
    var longitude: String
    var latitude: String
    
    init(name: String, week: [Int], day: [Int], fav: Int, hours: String,
         fix: [Int], add: String, tel: String, logi: String, lati: String) {
        self.name = name
        self.closedWeek = week
        self.closedDay = day
        self.favorite = fav
        self.openingHours = hours
        self.fixedClosedDay = fix
        self.address = add
        self.telNumber = tel
        self.longitude = logi
        self.latitude = lati
    }
}

class Locations {
    static let shared = Locations()
    private init() {}
    
    var currentLocation: CLLocation?
}

//struct Documents: Codable {
//    let documents: [Mart]
//}
//
//struct Mart: Codable {
//
//    var addressName: String?
//    var categoryGroupCode: String?
//    var categoryGroupName: String?
//    var categoryName: String?
//    var distance: String?
//    var id: String?
//    var phone: String?
//    var placeName: String?
//    var placeUrl: String?
//    var roadAddressName: String?
//    var x: String?
//    var y: String?
//
//    private enum CodingKeys: String, CodingKey {
//        case addressName = "address_name"
//        case categoryGroupCode = "category_group_code"
//        case categoryGroupName = "category_group_name"
//        case categoryName = "category_name"
//        case distance
//        case id
//        case phone
//        case placeName = "place_name"
//        case placeUrl = "place_url"
//        case roadAddressName = "road_address_name"
//        case x
//        case y
//    }
//
//    var description: String {
//        var des = ""
//        des = des.appending("   {\n")
//        des = des.appending("       addressName: \(self.addressName ?? ""),\n")
//        des = des.appending("       categoryGroupCode: \(self.categoryGroupCode ?? ""),\n")
//        des = des.appending("       categoryGroupName: \(self.categoryGroupName ?? ""),\n")
//        des = des.appending("       categoryName: \(self.categoryName ?? ""),\n")
//        des = des.appending("       distance: \(self.distance ?? ""),\n")
//        des = des.appending("       id: \(self.id ?? ""),\n")
//        des = des.appending("       phone: \(self.phone ?? ""),\n")
//        des = des.appending("       placeName: \(self.placeName ?? ""),\n")
//        des = des.appending("       placeUrl: \(self.placeUrl ?? ""),\n")
//        des = des.appending("       roadAddressName: \(self.roadAddressName ?? ""),\n")
//        des = des.appending("       x: \(self.x ?? ""),\n")
//        des = des.appending("       y: \(self.y ?? ""),\n")
//        des = des.appending("   }")
//        return des
//    }
//}


