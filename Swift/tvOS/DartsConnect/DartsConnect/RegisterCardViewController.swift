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
    
    // The current stage of user enrolment
    var stage = 1
    
    func cardScanned(cardID: String) {
        if stage == 3 {
            cardIDLabel.text = "Card ID: \(cardID)"
        }
    }
    
    /**
     Function wrapper for saving me one line of code whenever a view needs to be enabled
     
     - parameter enabled: The state of the view
     - parameter view:    The view to be enabled or disabled
     */
    func setInteraction(enabled:Bool, view:UIView) {
        view.userInteractionEnabled = enabled
        view.alpha = enabled ? 1 : 0.5
    }
    
    /**
     Registers the user's email address and a random password
     Then sends a password reset email to the specified email address
     Upon all of that succeeding, it will disable the email field and enable the password fields
     It will also change the title of the register button to 'Login'
     */
    private func stage1() {
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
    }
    
    /**
     This will reset the user's password to the password he entered.
     Upon completing that and succeeding, the function will prompt the user to scan a unassigned card
     and create a username
     It will also set the register button's title to 'Register User and Card'
     */
    private func stage2() {
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
    }
    
    /**
     This section completes the user registration process,
     However, if fields are missing, then it will alert the user
     the same goes for if a card is already registered, or a username already exists.
     All code here is self documenting, you should be able to read it :)
     */
    private func stage3() {
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
    
    /**
     Gets called whenever the 'register' button is called.
     Calls the appropriate function for the current stage of registration.
     */
    func register() {
        switch stage {
        case 1:
            stage1()
            break
        case 2:
            stage2()
            break
        case 3:
            stage3()
        default:
            break
        }
    }
    
    /**
     Returns to the Main menu view controller
     */
    func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// Set the initial focussed view in the view controller
    override var preferredFocusedView: UIView? {
        get {
            return emailField
        }
    }
    
    /**
     Sets the keyboard type to default
     Makes the keyboard show dots rather than characters for secure entry
     Disable user interaction, so they can be enabled later.
     
     - parameter textfield: The textfield to have the above applied to it.
     */
    func applyPasswordFieldAttributesTo(textfield:UITextField) {
        textfield.keyboardType = .Default
        textfield.secureTextEntry = true
        textfield.userInteractionEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create Card ID Label
        cardIDLabel.text = "Enter your email address below."
        cardIDLabel.font = UIFont.systemFontOfSize(50)
        cardIDLabel.adjustsFontSizeToFitWidth = true
        cardIDLabel.textAlignment = .Center
        cardIDLabel.alpha = 0.75
        
        // Customise emailField textfield
        emailField.keyboardType = .EmailAddress
        emailField.placeholder = "Email Address"
        
        // Customise the temporary password textfield
        applyPasswordFieldAttributesTo(tempPassField)
        tempPassField.placeholder = "Temporary Password"
        
        // Customise the new password textfield
        applyPasswordFieldAttributesTo(newPassField)
        newPassField.placeholder = "Password"
        
        // Customise the username textfield
        userNameField.keyboardType = .Default
        userNameField.placeholder = "Username"
        userNameField.userInteractionEnabled = false
        
        // Customise the cancel button
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.addTarget(self, action: #selector(RegisterCardViewController.cancel), forControlEvents: .PrimaryActionTriggered)
        
        // Customise the register user button
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.setTitle("Register Email", forState: .Normal)
        registerButton.addTarget(self, action: #selector(RegisterCardViewController.register), forControlEvents: .PrimaryActionTriggered)
        
        // Create a horizontal stackview and add the two, cancel and register buttons to it.
        let hStack:UIStackView = UIStackView(arrangedSubviews: [cancelButton, registerButton])
        hStack.axis = .Horizontal
        hStack.distribution = .EqualSpacing
        
        // Create a vertical stackview and add all of the textfields and the horizontal stackview created above.
        let vStack:UIStackView = UIStackView(arrangedSubviews: [cardIDLabel, emailField, tempPassField, newPassField, userNameField, hStack])
        vStack.axis = .Vertical
        vStack.distribution = .EqualSpacing
        self.view.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-100-[vStack]-100-|", options: .AlignAllCenterX, metrics: nil, views: ["vStack":vStack]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-100-[vStack]-100-|", options: .AlignAllCenterY, metrics: nil, views: ["vStack":vStack]))
        
        // Asign the same vertical height constraint to all textfields
        for textfield in vStack.arrangedSubviews where textfield is UITextField {
            textfield.translatesAutoresizingMaskIntoConstraints = false
            vStack.addConstraint(NSLayoutConstraint(item: textfield, attribute: .Height, relatedBy: .Equal, toItem: vStack, attribute: .Height, multiplier: 0.10, constant: 0))
        }
        
        
        GlobalVariables.sharedVariables.connector?.delegate = self
    }
}
