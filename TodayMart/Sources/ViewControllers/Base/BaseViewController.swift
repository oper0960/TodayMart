//
//  BaseViewController.swift
//  TodayMart
//
//  Created by Gilwan Ryu on 2019/11/25.
//  Copyright © 2019 Ry. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var keyboardHeight: CGFloat = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addNotification()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeNotification()
    }
    
    // MARK: Observers
    func addNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeNotification(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillChange(_ notification: Notification, keyboardSize: CGRect){}
}

extension BaseViewController{
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize1 = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        guard let keyboardSize2 = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        self.keyboardHeight = keyboardSize1.height == 0 ? keyboardSize2.height : keyboardSize1.height
        self.keyboardWillChange(notification, keyboardSize: keyboardSize1.height == 0 ? keyboardSize2 : keyboardSize1)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        self.keyboardWillChange(notification, keyboardSize: CGRect.zero)
    }
}
