//
//  Favorite.swift
//  TodayMart
//
//  Created by Gilwan Ryu on 2019/11/28.
//  Copyright © 2019 Ry. All rights reserved.
//

import UIKit

struct Favorite: Codable {

    var userId: String
    var martId: String
    
    private enum CodingKeys: String, CodingKey {
        case userId = "userId"
        case martId = "martId"
    }
    
    var description: String {
        var des = ""
        des = des.appending("   {\n")
        des = des.appending("       userId: \(self.userId),\n")
        des = des.appending("       martId: \(self.martId)\n")
        des = des.appending("   }")
        return des
    }
    
    func isFavorite(_ userId: String, martId: String) -> Bool {
        return self.userId == userId && self.martId == martId
    }
}
