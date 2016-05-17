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
    let passField:UITextField = UITextField()
    let userNameField:UITextField = UITextField()
    
    let cancelButton:UIButton = UIButton(type: .System)
    let registerButton:UIButton = UIButton(type: .System)
    
    func cardScanned(cardID: String) {
        cardIDLabel.text = "Card ID: \(cardID)"
    }
    
    func register() {
        if cardIDLabel.text == "Scan Card" {
            let alert = UIAlertController(title: "Scan Card", message: "Please scan a card to register to an account.", preferredStyle: .Alert)
            self.showViewController(alert, sender: self)
        }
        
        // You must scan a card that is not already registered to an account.
    }
    
    func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override var preferredFocusedView: UIView? {
        get {
            return emailField
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardIDLabel.text = "Scan Card"
        cardIDLabel.font = UIFont.systemFontOfSize(50)
        cardIDLabel.adjustsFontSizeToFitWidth = true
        cardIDLabel.textAlignment = .Center
        cardIDLabel.alpha = 0.75
        
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.keyboardType = .EmailAddress
        emailField.placeholder = "Email Address"
        
        userNameField.translatesAutoresizingMaskIntoConstraints = false
        userNameField.keyboardType = .Default
        userNameField.placeholder = "Username"
        
        passField.translatesAutoresizingMaskIntoConstraints = false
        passField.keyboardType = .Default
        passField.secureTextEntry = true
        passField.placeholder = "Password"
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.addTarget(self, action: #selector(RegisterCardViewController.cancel), forControlEvents: .PrimaryActionTriggered)
        
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.setTitle("Register Card", forState: .Normal)
        registerButton.addTarget(self, action: #selector(RegisterCardViewController.register), forControlEvents: .PrimaryActionTriggered)

        let hStack:UIStackView = UIStackView(arrangedSubviews: [cancelButton, registerButton])
        hStack.axis = .Horizontal
        hStack.distribution = .EqualSpacing
        
        let vStack:UIStackView = UIStackView(arrangedSubviews: [cardIDLabel, emailField, userNameField, passField, hStack])
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
