//
//  Mart.swift
//  ClosedMart
//
//  Created by Gilwan Ryu on 2018. 6. 11..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit
import CoreLocation
import KeychainSwift

typealias name = String
typealias closedWeek = [Int]
typealias closedDay = [Int]
typealias fixedClosedDay = [Int]

struct Mart: Codable {

    var name: name
    var closedWeek: String
    var closedDay: String
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
        case openingHours = "OpeningHours"
        case fixedClosedDay = "FixedClosedDay"
        case address = "Address"
        case telNumber = "TelNumber"
        case longitude = "Longitude"
        case latitude = "Latitude"
        case id = "id"
    }
    
    var splitClosedWeek: closedWeek {
        var week = [Int]()
        _ = closedWeek.components(separatedBy: ",").map {
            week.append(Int($0) ?? 0)
        }
        return week
    }
    
    var splitClosedDay: closedDay {
        var week = [Int]()
        _ = closedDay.components(separatedBy: ",").map {
            week.append(Int($0) ?? 0)
        }
        return week
    }
    
    var splitFixedClosedDay: fixedClosedDay {
        var week = [Int]()
        _ = fixedClosedDay.components(separatedBy: ",").map {
            week.append(Int($0) ?? 0)
        }
        return week
    }

    var description: String {
        var des = ""
        des = des.appending("   {\n")
        des = des.appending("       name: \(self.name),\n")
        des = des.appending("       closedWeek: \(self.closedWeek),\n")
        des = des.appending("       closedDay: \(self.closedDay),\n")
        des = des.appending("       openingHours: \(self.openingHours),\n")
        des = des.appending("       fixedClosedDay: \(self.fixedClosedDay),\n")
        des = des.appending("       address: \(self.address),\n")
        des = des.appending("       telNumber: \(self.telNumber),\n")
        des = des.appending("       telNumber: \(self.telNumber),\n")
        des = des.appending("       longitude: \(self.longitude),\n")
        des = des.appending("       latitude: \(self.latitude)\n")
        des = des.appending("   }")
        return des
    }
}


