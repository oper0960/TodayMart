//
//  UIColorExtension.swift
//  ClosedMart
//
//  Created by Gilwan Ryu on 2018. 6. 8..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex16: UInt16) {
        let alpha = CGFloat((hex16 >> 12) & 0xf) / 0xf
        let red = CGFloat((hex16 >> 8) & 0xf) / 0xf
        let green = CGFloat((hex16 >> 4) & 0xf) / 0xf
        let blue = CGFloat(hex16 & 0xf) / 0xf
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    convenience init (hex32: UInt32) {
        let alpha = CGFloat((hex32 >> 24) & 0xff) / 0xff
        let red = CGFloat((hex32 >> 16) & 0xff) / 0xff
        let green = CGFloat((hex32 >> 8) & 0xff) / 0xff
        let blue = CGFloat(hex32 & 0xff) / 0xff
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    convenience init (hex32: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex32 >> 16) & 0xff) / 0xff
        let green = CGFloat((hex32 >> 8) & 0xff) / 0xff
        let blue = CGFloat(hex32 & 0xff) /
        0xff
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    convenience init?(hexString: String) {
        if !hexString.hasPrefix("#") {
            return nil
        }
        var hexStr = hexString
        hexStr.remove(at: hexStr.startIndex)
        switch hexStr.count {
        case 3:
            hexStr = "f" + hexStr
            fallthrough
        case 4:
            guard let hex16 = UInt16(hexStr, radix: 16) else {
                return nil
            }
            self.init(hex16: hex16)
        case 6:
            hexStr = "ff" + hexStr
            fallthrough
        case 8:
            guard let hex32 = UInt32(hexStr, radix: 16) else {
                return nil
            }
            self.init(hex32: hex32)
        default:
            return nil
        }
    }
}

extension UINavigationController {
    
    func pushViewController(_ viewController: UIViewController, back: String, animated: Bool) {
        if let controller = self.viewControllers.last {
            let backButton = UIBarButtonItem(title: back, style:.plain, target: nil, action: nil)
            controller.navigationItem.backBarButtonItem = backButton
        }
        pushViewController(viewController, animated: animated)
    }
}
