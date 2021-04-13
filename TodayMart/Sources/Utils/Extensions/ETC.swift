//
//  ETC.swift
//  ClosedMart
//
//  Created by Gilwan Ryu on 2018. 10. 17..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit

let userDefault = UserDefaults.standard

// UserDefault Key
struct UserSettings {
    // POI Clustering Animation
    static let clusterRendererAnimation: String = "clusterRendererAnimation"
    // Close Day Notification
    static let localNotificationMartID: String = "localNotificationMartID"
}

enum Admob {
    case banner
    
    var id: String {
        switch self {
        case .banner:
            #if DEBUG
            return "ca-app-pub-3940256099942544/2934735716"
            #else
            return "ca-app-pub-9335296893721653/6964742992"
            #endif
        }
    }
}


