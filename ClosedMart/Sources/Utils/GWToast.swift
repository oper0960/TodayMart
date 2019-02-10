//
//  GWToast.swift
//  Pods
//
//  Created by Gilwan Ryu on 2017. 5. 9..
//
//

import UIKit

public enum ToastPosition: Int {
    case Top
    case Center
    case Bottom
}

public class GWToast {
    
    private let mMessage: String
    private static var BackgroundColor = UIColor.white
    private static var TextColor = UIColor.black
    private static var ToastDuration: TimeInterval = 1
    private static var Position = ToastPosition.Center
    
    private static let ANIMATION_DURATION = 0.4
    private static let PADDING :CGFloat = 8
    private static let CORNER_RADIUS : CGFloat = 6
    private static let FONT_SIZE: CGFloat = 15
    private static let MAX_SIZE_RATIO_FROM_WINDOW :CGFloat = 0.75
    
    
    public init(message: String){
        mMessage = message
    }
    
    public func setDuration(duration: TimeInterval) -> GWToast {
        GWToast.ToastDuration = duration
        return self
    }
    
    public func setBackgroundColor(color: UIColor) -> GWToast {
        GWToast.BackgroundColor = color
        return self;
    }
    
    public func setPosition(position: ToastPosition) -> GWToast {
        GWToast.Position = position
        return self
    }
    
    public func setTextcolor(color: UIColor) -> GWToast {
        GWToast.TextColor = color
        return self
    }
    
    public func show(){
        let toastView = makeToast()
        toastView.center = centerPoint()
        toastView.alpha = 0
        
        UIApplication.shared.delegate?.window??.addSubview(toastView)
        
        UIView.animate(withDuration: GWToast.ANIMATION_DURATION, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            toastView.alpha = 0.8
        }) { (result) -> Void in
            self.removeToast(toastView: toastView)
        }
    }
    
    private func removeToast(toastView: UIView){
        UIView.animate(withDuration: GWToast.ANIMATION_DURATION, delay: GWToast.ToastDuration, options: .curveEaseIn, animations: { () -> Void in
            toastView.alpha = 0
        }) { (result) -> Void in
            toastView.removeFromSuperview()
        }
    }
    
    private func centerPoint() -> CGPoint {
        let posX = UIScreen.main.bounds.width / 2
        let screenHeight = UIScreen.main.bounds.height
        
        var posY:CGFloat
        
        switch GWToast.Position {
        case .Top: posY = screenHeight / 4
        case .Center: posY = screenHeight / 2
        case .Bottom: posY = screenHeight / 4 * 3
        }
        
        return CGPoint(x:posX, y:posY)
    }
    
    private func makeToast() -> UIView {
        
        let windowWidth = UIScreen.main.bounds.width
        let windowHeight = UIScreen.main.bounds.height
        
        
        let viewBackground = UIView()
        viewBackground.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        viewBackground.layer.cornerRadius = GWToast.CORNER_RADIUS
        viewBackground.backgroundColor = GWToast.BackgroundColor
        
        viewBackground.layer.shadowColor = UIColor.black.cgColor
        viewBackground.layer.shadowOpacity = 0.9
        viewBackground.layer.shadowRadius = GWToast.CORNER_RADIUS
        viewBackground.layer.shadowOffset = CGSize(width:3, height:3)
        
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: GWToast.FONT_SIZE)
        label.textAlignment = .natural
        label.lineBreakMode = .byWordWrapping
        label.textColor = GWToast.TextColor
        label.backgroundColor = UIColor.clear
        label.text = mMessage
        label.alpha = 0.9
        
        let maxSizeMessage = CGSize(width:windowWidth * GWToast.MAX_SIZE_RATIO_FROM_WINDOW, height:windowHeight * GWToast.MAX_SIZE_RATIO_FROM_WINDOW)
        let expectedSizeMessage = sizeForString(msg: mMessage, font: label.font, constrainedToSize: maxSizeMessage, lineBreakMode: label.lineBreakMode)
        
        label.frame = CGRect(x:GWToast.PADDING, y:GWToast.PADDING, width:expectedSizeMessage.width, height:expectedSizeMessage.height)
        
        let backgroundWidth = label.bounds.width + (GWToast.PADDING * 2)
        let backgroundHeight = label.bounds.height + (GWToast.PADDING * 2)
        viewBackground.frame = CGRect(x:0, y:0, width:backgroundWidth, height:backgroundHeight)
        
        viewBackground.addSubview(label)
        
        return viewBackground
    }
    
    private func sizeForString(msg: String, font:UIFont, constrainedToSize:CGSize, lineBreakMode: NSLineBreakMode) -> CGSize {
        
        let string = NSString(string: msg)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = lineBreakMode
        
        let attributes = [kCTFontAttributeName:font, kCTParagraphStyleAttributeName:paragraphStyle]
        
        let boundingRect = string.boundingRect(with: constrainedToSize, options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedStringKey : Any], context: nil)
        
        let widthFloat = ceilf(Float(boundingRect.size.width))
        let heightFloat = ceilf(Float(boundingRect.size.height))
        
        return CGSize(width:CGFloat(widthFloat), height:CGFloat(heightFloat))
    }
}

