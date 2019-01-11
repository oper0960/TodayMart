//
//  FavoriteTableViewCell.swift
//  ClosedMart
//
//  Created by Ryu on 2018. 10. 16..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var offDay: UILabel!
    @IBOutlet weak var workTime: UILabel!
    @IBOutlet weak var status: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
