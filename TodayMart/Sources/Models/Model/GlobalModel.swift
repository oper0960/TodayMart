//
//  GlobalModel.swift
//  TodayMart
//
//  Created by Buxi on 2019/11/28.
//  Copyright © 2019 Ry. All rights reserved.
//

import UIKit
import KeychainSwift

class User {
    static let current = User()
    private init() {}
    
    var uuid: String!
}


// MARK: - Current Location Singleton
class Locations {
    static let shared = Locations()
    private init() {}
    
    var currentLocation: CLLocation?
}

// MARK: - Keychain Singleton
class Keychain {
    static let current = KeychainSwift()
    private init() {}
}

struct KeychainKey {
    static let uuid: String = "userId"
}
