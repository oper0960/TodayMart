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
//
//class Mart {
//    var name: name
//    var closedWeek: closedWeek
//    var closedDay: closedDay
//    var favorite: Int
//    var openingHours: String
//    var fixedClosedDay: fixedClosedDay
//    var address: String
//    var telNumber: String
//    var longitude: String
//    var latitude: String
//
//    init(name: String, week: [Int], day: [Int], fav: Int, hours: String,
//         fix: [Int], add: String, tel: String, logi: String, lati: String) {
//        self.name = name
//        self.closedWeek = week
//        self.closedDay = day
//        self.favorite = fav
//        self.openingHours = hours
//        self.fixedClosedDay = fix
//        self.address = add
//        self.telNumber = tel
//        self.longitude = logi
//        self.latitude = lati
//    }
//}

class Locations {
    static let shared = Locations()
    private init() {}
    
    var currentLocation: CLLocation?
}

struct Mart: Codable {

    var name: name
    var closedWeek: String
    var closedDay: String
    var favorite: Int
    var openingHours: String
    var fixedClosedDay: String
    var address: String
    var telNumber: String
    var longitude: Double
    var latitude: Double
    var id: Int

    private enum CodingKeys: String, CodingKey {
        case name = "Name"
        case closedWeek = "ClosedWeek"
        case closedDay = "ClosedDay"
        case favorite = "Favorite"
        case openingHours = "OpeningHours"
        case fixedClosedDay = "FixedClosedDay"
        case address = "Address"
        case telNumber = "TelNumber"
        case longitude = "Longitude"
        case latitude = "Latitude"
        case id = "id"
    }

//    var description: String {
//        var des = ""
//        des = des.appending("   {\n")
//        des = des.appending("       name: \(self.name ?? ""),\n")
//        des = des.appending("       closedWeek: \(self.closedWeek ?? ""),\n")
//        des = des.appending("       closedDay: \(self.closedDay ?? ""),\n")
//        des = des.appending("       favorite: \(self.favorite ?? ""),\n")
//        des = des.appending("       openingHours: \(self.openingHours ?? ""),\n")
//        des = des.appending("       fixedClosedDay: \(self.fixedClosedDay ?? ""),\n")
//        des = des.appending("       address: \(self.address ?? ""),\n")
//        des = des.appending("       telNumber: \(self.telNumber ?? ""),\n")
//        des = des.appending("       telNumber: \(self.telNumber ?? ""),\n")
//        des = des.appending("       longitude: \(self.longitude ?? ""),\n")
//        des = des.appending("       latitude: \(self.latitude ?? ""),\n")
//        des = des.appending("   }")
//        return des
//    }
}


