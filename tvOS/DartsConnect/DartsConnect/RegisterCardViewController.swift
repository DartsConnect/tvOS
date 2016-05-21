//
//  RegisterCardViewController.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 17/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class RegisterCardViewController: UIViewController, ConnectorDelegate {
    /*
     Fields: email, username, password
    */
    let cardIDLabel:UILabel = UILabel()
    
    let emailField:UITextField = UITextField()
    let tempPassField:UITextField = UITextField()
    let newPassField:UITextField = UITextField()
    let userNameField:UITextField = UITextField()
    
    let cancelButton:UIButton = UIButton(type: .System)
    let registerButton:UIButton = UIButton(type: .System)
    
    var uid:String?
    
    var stage = 1
    
    func cardScanned(cardID: String) {
        if stage == 3 {
            cardIDLabel.text = "Card ID: \(cardID)"
        }
    }
    
    func setInteraction(enabled:Bool, view:UIView) {
        view.userInteractionEnabled = enabled
        view.alpha = enabled ? 1 : 0.5
    }
    
    func register() {
        if stage == 1 {
            GlobalVariables.sharedVariables.dbManager.beginAccountCreation(emailField.text!, completion: {
                errorString in
                if errorString == nil {
                    
                    self.stage = 2
                    self.cardIDLabel.text = "Enter your new password."
                    self.registerButton.setTitle("Login", forState: .Normal)
                    self.setInteraction(false, view: self.emailField)
                    self.setInteraction(true, view: self.tempPassField)
                    self.setInteraction(true, view: self.newPassField)
                    
                    let alert = UIAlertController(title: "Successfully Created Account", message: "You have been sent a password resent email to \(self.emailField.text!). Reset your password, and login in to complete the second stage of account creation.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                    self.showViewController(alert, sender: self)
                } else {
                    let alert = UIAlertController(title: errorString!, message: "Please check your Internet connection or try again at a later time.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                    self.showViewController(alert, sender: self)
                }
            })
        } else if stage == 2 {
            
            GlobalVariables.sharedVariables.dbManager.resetPasswordFor(emailField.text!, tempPass: tempPassField.text!, newPass: newPassField.text!, completion: {
                error, t_uid in
                if error == nil {
                    self.stage = 3
                    self.cardIDLabel.text = "Scan Card"
                    self.setInteraction(false, view: self.tempPassField)
                    self.setInteraction(false, view: self.newPassField)
                    self.setInteraction(true, view: self.userNameField)
                    self.registerButton.setTitle("Register Username and Card", forState: .Normal)
                    self.uid = t_uid!
                } else {
                    let alert = UIAlertController(title: "Failed to Login", message: error!.description, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                    self.showViewController(alert, sender: self)
                }
            })
            
        } else if stage == 3{
            if cardIDLabel.text == "Scan Card" {
                let alert = UIAlertController(title: "Scan Card", message: "Please scan a card to register to an account.", preferredStyle: .Alert)
                self.showViewController(alert, sender: self)
            } else {
                let cardID = cardIDLabel.text!.componentsSeparatedByString(": ")[1]
                
                
                GlobalVariables.sharedVariables.dbManager.isCardAlreadyRegistered(cardID, completion: {
                    isCardAvailable in
                    if isCardAvailable {
                        GlobalVariables.sharedVariables.dbManager.isUsernameAvailable(self.userNameField.text!, completion: {
                            isUsernameAvailable in
                            if isUsernameAvailable {
                                GlobalVariables.sharedVariables.dbManager.registerCard(cardID, uid: self.uid!, email: self.emailField.text!, username: self.userNameField.text!)
                                self.cancel()
                            } else {
                                let alert = UIAlertController(title: "Username not available.", message: "Please pick another username.", preferredStyle: .Alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                                self.showViewController(alert, sender: self)
                            }
                        })
                    } else {
                        let alert = UIAlertController(title: "Card already registered.", message: "The card you have scanned is already registered to another account.", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                        self.showViewController(alert, sender: self)
                    }
                })
            }
        }
    }
    
    func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override var preferredFocusedView: UIView? {
        get {
            return emailField
        }
    }
    
    func applyPasswordFieldAttributesTo(textfield:UITextField) {
        textfield.keyboardType = .Default
        textfield.secureTextEntry = true
        textfield.userInteractionEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardIDLabel.text = "Enter your email address below."
        cardIDLabel.font = UIFont.systemFontOfSize(50)
        cardIDLabel.adjustsFontSizeToFitWidth = true
        cardIDLabel.textAlignment = .Center
        cardIDLabel.alpha = 0.75
        
        emailField.keyboardType = .EmailAddress
        emailField.placeholder = "Email Address"
        
        applyPasswordFieldAttributesTo(tempPassField)
        tempPassField.placeholder = "Temporary Password"
        
        applyPasswordFieldAttributesTo(newPassField)
        newPassField.placeholder = "Password"
        
        userNameField.keyboardType = .Default
        userNameField.placeholder = "Username"
        userNameField.userInteractionEnabled = false
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.addTarget(self, action: #selector(RegisterCardViewController.cancel), forControlEvents: .PrimaryActionTriggered)
        
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.setTitle("Register Email", forState: .Normal)
        registerButton.addTarget(self, action: #selector(RegisterCardViewController.register), forControlEvents: .PrimaryActionTriggered)

        let hStack:UIStackView = UIStackView(arrangedSubviews: [cancelButton, registerButton])
        hStack.axis = .Horizontal
        hStack.distribution = .EqualSpacing
        
        let vStack:UIStackView = UIStackView(arrangedSubviews: [cardIDLabel, emailField, tempPassField, newPassField, userNameField, hStack])
        vStack.axis = .Vertical
        vStack.distribution = .EqualSpacing
        self.view.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-100-[vStack]-100-|", options: .AlignAllCenterX, metrics: nil, views: ["vStack":vStack]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-100-[vStack]-100-|", options: .AlignAllCenterY, metrics: nil, views: ["vStack":vStack]))
        
        for textfield in vStack.arrangedSubviews where textfield is UITextField {
            textfield.translatesAutoresizingMaskIntoConstraints = false
            vStack.addConstraint(NSLayoutConstraint(item: textfield, attribute: .Height, relatedBy: .Equal, toItem: vStack, attribute: .Height, multiplier: 0.10, constant: 0))
        }
        
        
        GlobalVariables.sharedVariables.connector?.delegate = self
    }
}
