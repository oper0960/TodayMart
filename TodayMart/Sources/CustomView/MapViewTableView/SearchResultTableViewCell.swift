//
//  SearchResultTableViewCell.swift
//  TodayMart
//
//  Created by Gilwan Ryu on 09/05/2019.
//  Copyright © 2019 Ry. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pinButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
