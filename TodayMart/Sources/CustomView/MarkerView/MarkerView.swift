//
//  MarkerView.swift
//  ClosedMart
//
//  Created by Gilwan Ryu on 2018. 6. 25..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit

class MarkerView: UIView {
    
    class func instanceFromNib() -> MarkerView {
        return UINib(nibName: "MarkerView", bundle: nil).instantiate(withOwner: self, options: nil).first as! MarkerView
    }
    
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var workTime: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var closedWeek: UILabel!
    @IBOutlet weak var onSaleYN: UILabel!
    @IBOutlet weak var favorite: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
    }
}
