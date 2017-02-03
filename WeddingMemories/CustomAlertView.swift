//
//  CustomAlertView.swift
//  WeddingMemories
//
//  Created by Tyler Lafferty on 1/25/17.
//  Copyright © 2017 Tyler Lafferty. All rights reserved.
//

import Foundation
import UIKit

// -------------------------------------------------------------------
// -------------------------------------------------------------------
// ------------------------ ALERT VIEW -----------------------------
// -------------------------------------------------------------------
// -------------------------------------------------------------------

enum AlertType {
    case Text, TextField, Loader
}

class CustomAlertView : UIView {
    
    var alertBackgroundView : UIView!
    var closeAction:(()->Void)!
    var cancelAction:(()->Void)!
    var confirm: CustomAlertAction!
    var cancel: CustomAlertAction!
    var dismissButton : UIButton!
    var cancelButton: UIButton!
    var blurView: UIVisualEffectView!
    
    // Sizing setup
    let baseHeight: CGFloat = 400.0
    let alertWidth: CGFloat = 450.0
    let buttonHeight: CGFloat = 70.0
    let padding: CGFloat = 20.0
    let viewWidth:CGFloat = UIScreen.main.bounds.width
    let viewHeight:CGFloat = UIScreen.main.bounds.height
    var yPos: CGFloat = 0.0
    var contentWidth: CGFloat!
    var buttonWidth: CGFloat!
    
    func showAlertView(superview: UIView, title: String, text: String, type: AlertType, img: String?=nil, confirmAction: CustomAlertAction?=nil, cancelAction: CustomAlertAction?=nil) {

        // The two actions that get passed in
        confirm = confirmAction
        cancel = cancelAction
        contentWidth = alertWidth - (padding*2)

        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

        blurView.frame = CGRect(x: 0, y: 0, width: superview.frame.width, height: superview.frame.height)
        self.addSubview(blurView)
        self.backgroundColor = UIColor.clear
        superview.addSubview(self)
        superview.bringSubview(toFront: self)
        
        // Background view
        // Every subview gets add to the alertBackgroundView which then
        // gets added to the superview
        alertBackgroundView = UIView()
        alertBackgroundView.backgroundColor = UIColor.darkGray
        alertBackgroundView.layer.cornerRadius = 4
        alertBackgroundView.clipsToBounds = true
        self.addSubview(alertBackgroundView)
        // Icon
        if img != nil {
            setupImageView(img: img!)
        }
        // Title
        setupTitleLabel(title: title)
        
        // Message Text
        switch type {
        case .Text:
            setupMessageText(text: text)
        case .TextField:
            setupTextField(text: text)
        case .Loader:
            break
        }
        
        // Add to padding
        yPos += padding
        buttonWidth = alertWidth
        
        // Second cancel button
        if cancel != nil {
            setupCancelButton()
        }
        
        // Confirm Button
        setupConfirmButton()
        yPos += buttonHeight
        alertBackgroundView.frame = CGRect(x: (viewWidth-alertWidth)/2, y: (superview.frame.height-yPos)/2, width: alertWidth, height: yPos)
        self.frame = CGRect(x: 0, y: 0, width: superview.frame.width, height: superview.frame.height)
        alertBackgroundView.center.x = superview.center.x
        alertBackgroundView.center.y = -500
        blurView.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
            self.blurView.alpha = 1
            self.alertBackgroundView.center = CGPoint(x: self.alertBackgroundView.center.x, y: superview.frame.height/2)
        }) { (Bool) -> Void in
            
        }
    }
    
    // ------------------------------------------------------------
    // -- Button taps call the handler that is setup up when making
    // -- the alert view. If no actions are passed in, the button will
    // -- just dismiss the alert.
    // ------------------------------------------------------------
    func buttonTap() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
            self.blurView.alpha = 0
            self.alertBackgroundView.center.y += 500
        }, completion: { (Bool) -> Void in
            self.removeFromSuperview()
            if self.confirm != nil {
                self.confirm.handler()
            }
        })
    }
    
    func cancelButtonTap() {
        closeAlert()
        if cancel != nil {
            cancel.handler()
        }
    }
    
    // Used to close the alert view
    func closeAlert() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
            self.blurView.alpha = 0
            self.alertBackgroundView.center.y += 500
        }, completion: { (Bool) -> Void in
            self.removeFromSuperview()
        })
    }
}

// MARK: Setup Functions
extension CustomAlertView {
    /// Setup the image view
    func setupImageView(img : String) {
        let iconImageView : UIImageView! = UIImageView()
        let image = UIImage(named: img)?.withRenderingMode(.alwaysTemplate)
        iconImageView.image = image
        iconImageView.tintColor = UIColor.white
        let centerX = (alertWidth-iconImageView.frame.width)/2
        iconImageView.frame = CGRect(x: centerX, y: padding, width: (image?.size.width)!, height: (image?.size.height)!)
        iconImageView.center = CGPoint(x: alertWidth/2, y: iconImageView.center.y)
        iconImageView.contentMode = .center
        yPos += iconImageView.frame.height
        alertBackgroundView.addSubview(iconImageView)
        yPos += padding
    }
    
    /// Setup the title Label
    func setupTitleLabel(title : String) {
        let titleLbl = UILabel()
        titleLbl.textColor = UIColor.white
        titleLbl.numberOfLines = 0
        titleLbl.textAlignment = .center
        titleLbl.font = UIFont(name: "HelveticaNeue-Light", size: 30)
        titleLbl.text = title
        let titleString = titleLbl.text! as NSString
        let titleAttr = [NSFontAttributeName:titleLbl.font]
        let titleSize = CGSize(width: contentWidth, height: 90)
        let titleRect = titleString.boundingRect(with: titleSize, options: .usesLineFragmentOrigin, attributes: titleAttr, context: nil)
        yPos += padding
        titleLbl.frame = CGRect(x: padding, y: yPos, width: alertWidth-(padding*2), height: ceil(titleRect.size
            .height))
        yPos += ceil(titleRect.size.height)
        alertBackgroundView.addSubview(titleLbl)
    }
    
    /// Setup message text field
    func setupTextField(text : String) {
        let textView = UITextField()
        textView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textView.textColor = UIColor.white
        textView.textAlignment = .center
        textView.font = UIFont(name: "HelveticaNeue", size: 16)
        textView.backgroundColor = UIColor.clear
        textView.placeholder = text
        textView.keyboardType = .emailAddress
        textView.delegate = self
        let textString = textView.text! as NSString
        let textAttr = [NSFontAttributeName:textView.font as AnyObject]
        let realSize = textView.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))//CGSizeMake(contentWidth, CGFloat.max))
        let textSize = CGSize(width: contentWidth, height: CGFloat(fmaxf(Float(90.0), Float(realSize.height))))
        let textRect = textString.boundingRect(with: textSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: textAttr, context: nil)
        textView.frame = CGRect(x: padding, y: yPos, width: alertWidth - (padding*2), height: ceil(textRect.size.height)*2)
        yPos += ceil(textRect.size.height) + padding/2
        alertBackgroundView.addSubview(textView)
    }
    
    /// Setup message text
    func setupMessageText(text : String) {
        let textView = UITextView()
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.textColor = UIColor.white
        textView.textAlignment = .center
        textView.font = UIFont(name: "HelveticaNeue", size: 16)
        textView.backgroundColor = UIColor.clear
        textView.text = text
        let textString = textView.text! as NSString
        let textAttr = [NSFontAttributeName:textView.font as AnyObject]
        let realSize = textView.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))//CGSizeMake(contentWidth, CGFloat.max))
        let textSize = CGSize(width: contentWidth, height: CGFloat(fmaxf(Float(90.0), Float(realSize.height))))
        let textRect = textString.boundingRect(with: textSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: textAttr, context: nil)
        textView.frame = CGRect(x: padding, y: yPos, width: alertWidth - (padding*2), height: ceil(textRect.size.height)*2)
        yPos += ceil(textRect.size.height) + padding/2
        alertBackgroundView.addSubview(textView)
    }
    
    /// Setup the alert with a loader
    func setupLoader() {
        
    }
    
    /// Setup Cancel Button
    func setupCancelButton() {
        buttonWidth = alertWidth/2
        cancelButton = UIButton()
        cancelButton.backgroundColor = UIColor.darkGray
        
        cancelButton.addTarget(self, action: #selector(CustomAlertView.cancelButtonTap), for: .touchUpInside)
        cancelButton.frame = CGRect(x: 0, y: yPos, width: buttonWidth-1, height: buttonHeight)
        alertBackgroundView.addSubview(cancelButton)
        // Button text
        let cancelButtonLabel = UILabel()
        cancelButtonLabel.alpha = 0.7
        cancelButtonLabel.textColor = UIColor.white
        cancelButtonLabel.numberOfLines = 1
        cancelButtonLabel.textAlignment = .center
        cancelButtonLabel.text = cancel.title
        cancelButtonLabel.frame = CGRect(x: padding, y: (buttonHeight/2)-15, width: buttonWidth-(padding*2), height: 30)
        cancelButton.addSubview(cancelButtonLabel)
    }
    
    /// Setup Confirm Button
    func setupConfirmButton() {
        dismissButton = UIButton()
        dismissButton.backgroundColor = UIColor.darkGray
        //dismissButton.addTarget(self, action: "buttonTap", forControlEvents: .TouchUpInside)
        dismissButton.addTarget(self, action: #selector(CustomAlertView.buttonTap), for: .touchUpInside)
        let buttonX = buttonWidth == alertWidth ? 0 : buttonWidth
        dismissButton.frame = CGRect(x: buttonX!, y: yPos, width: buttonWidth, height: buttonHeight)
        alertBackgroundView.addSubview(dismissButton)
        // Button text
        let buttonLabel = UILabel()
        buttonLabel.textColor = UIColor.white
        buttonLabel.numberOfLines = 1
        buttonLabel.textAlignment = .center
        if confirm != nil {
            buttonLabel.text = confirm.title
        } else {
            buttonLabel.text = "OK"
        }
        buttonLabel.frame = CGRect(x: padding, y: (buttonHeight/2)-15, width: buttonWidth-(padding*2), height: 30)
        dismissButton.addSubview(buttonLabel)
    }
}

// MARK: - Text Field Delegate
extension CustomAlertView : UITextFieldDelegate {
    func textFieldDidChange(_ textField: UITextField) {
        if let email = textField.text {
            WMShared.sharedInstance.userContact = email
        }
    }
}

// MARK: AmTrustAlertView Helpers
extension CustomAlertView {
    func adjustBrightness(color:UIColor, amount:CGFloat) -> UIColor {
        var hue:CGFloat = 0
        var saturation:CGFloat = 0
        var brightness:CGFloat = 0
        var alpha:CGFloat = 0
        if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            brightness += (amount-1.0)
            brightness = max(min(brightness, 1.0), 0.0)
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        return color
    }
}

// MARK: AmTrustAlertActions
// -------------------------------------------------
// -- These are used to call functions in the parent
// -- class when a button on the alert view is clicked
// -------------------------------------------------
class CustomAlertAction : NSObject {
    
    public var handler : () -> Void
    public var title : String
    
    public init(title: String, handler: (() -> Void)?) {
        self.title = title
        self.handler = handler!
    }
}
