//
//  MarkerCalendarTableViewCell.swift
//  TodayMart
//
//  Created by Buxi on 2020/01/09.
//  Copyright © 2020 Ry. All rights reserved.
//

import UIKit
import JTAppleCalendar

class MarkerCalendarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var calendarCollectionView: JTACMonthView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
