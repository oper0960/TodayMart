//
//  OptionTableViewCell.swift
//  TodayMart
//
//  Created by Gilwan Ryu on 22/04/2019.
//  Copyright © 2019 Ry. All rights reserved.
//

import UIKit

class OptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var optionSwitch: UISwitch!
    
    var menu: SettingOptionsViewController.OptionMenu?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func optionSwitch(_ sender: UISwitch) {
        
        guard let menu = menu else { return }
        switch menu {
        case .rendererAnimation:
            userDefault.set(sender.isOn, forKey: UserSettings.clusterRendererAnimation)
        }
    }
}
