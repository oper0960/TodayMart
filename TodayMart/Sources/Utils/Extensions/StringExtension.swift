//
//  StringExtension.swift
//  TodayMart
//
//  Created by Gilwan Ryu on 09/05/2019.
//  Copyright © 2019 Ry. All rights reserved.
//

import UIKit

extension String {
    var isKorean: Bool{
        return NSPredicate(format: "SELF MATCHES %@", ".*[ㄱ-ㅎㅏ-ㅣ가-힣]+.*").evaluate(with: self)
    }
}
