//
//  OpenSourceTextViewController.swift
//  BankQ
//
//  Created by Gilwan Ryu on 11/02/2019.
//  Copyright © 2019 BeyondPlatformService. All rights reserved.
//

import UIKit

class OpenSourceTextViewController: UIViewController {

    @IBOutlet weak var mainTextView: UITextView!
    
    var opensource: OpenSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension OpenSourceTextViewController {
    func setup() {
        
        mainTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 161, right: 16)
        
        guard let opensource = opensource else {
            title = "Empty License"
            mainTextView.text = ""
            return
        }
        title = opensource.opensourceName
        mainTextView.text = opensource.license.licenseText
    }
}
