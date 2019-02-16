//
//  OpenSourceTableViewCell.swift
//  BankQ
//
//  Created by Gilwan Ryu on 11/02/2019.
//  Copyright © 2019 BeyondPlatformService. All rights reserved.
//

import UIKit

class OpenSourceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var licenseLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
