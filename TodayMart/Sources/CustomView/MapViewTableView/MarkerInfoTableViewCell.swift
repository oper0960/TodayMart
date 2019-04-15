//
//  MarkerInfoTableViewCell.swift
//  TodayMart
//
//  Created by Gilwan Ryu on 15/04/2019.
//  Copyright © 2019 Ry. All rights reserved.
//

import UIKit

class MarkerInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
