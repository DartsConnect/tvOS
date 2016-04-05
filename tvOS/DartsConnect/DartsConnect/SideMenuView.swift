//
//  SideMenuView.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 13/02/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class SideMenuView: UIView {
    
    // Sizing
    let width:CGFloat = 450
    let padding:CGFloat = 50
    
    // Other UI
    let header:UILabel = UILabel(frame: CGRectZero)
    
    // Options
    let vStack:UIStackView = UIStackView(frame: CGRectZero)
    let gamesOptions:[String:[String:[String]]] = [
        "0:01":[
            "0:Type":["301", "501", "701", "901", "1001"],
            "1:Open":["Any", "Single", "Double", "Triple", "Bull", "Double Bull"],
            "2:Close":["Any", "Single", "Double", "Triple", "Bull", "Double Bull"],
            "3:Add Players":["1+"]
        ],
        "1:Cricket":[
            "0:Type":["Cricket", "Cut-Throat"],
            "1:Add Players":["2+"]
        ],
        "2:Free":[
            "Type":["Cricket", "Cut-Throat"],
            "Add Players":["1+"]
        ],
        "3:20 to 1":[
            "Type":["Cricket", "Cut-Throat"],
            "Add Players":["2+"]
        ],
        "4:World":[
            "Type":["Cricket", "Cut-Throat"],
            "Add Players":["1+"]
        ],
        "5:More":[
            "Type":["Cricket", "Cut-Throat"],
            "Add Players":["2+"]
        ]
        
    ]
    var breadcrumbs:[String] = []
    
    
    
    
    
    
    
    func buttonSelected(sender:UIButton) {
        animateButtonsOut()
        
        if sender.currentTitle! == "Begin Game" {
            print("Begin Game")
        } else {
            let index = vStack.subviews.indexOf(sender)!
            let originalName = "\(index):\(sender.currentTitle!)"
            var buttonsToCreate:[String] = []
            
            if sender.currentTitle! == "Back" {
                breadcrumbs.popLast()
            } else {
                breadcrumbs.append(originalName)
            }
            
            if breadcrumbs.count > 0 {
                let sub = [String](gamesOptions[breadcrumbs[0]]!.keys).sort()
                
                buttonsToCreate = gamesOptions[breadcrumbs[0]]![sub[breadcrumbs.count-1]]!
                buttonsToCreate.append("Back")
                
                if breadcrumbs.count <= 1 && sender.currentTitle! != "Back" {
                    header.text = sender.currentTitle!
                } else {
                    header.text = (breadcrumbs.count == 1 ? breadcrumbs[0]:sub[breadcrumbs.count - 1]).componentsSeparatedByString(":")[1]
                }
                
                if header.text == "Add Players" {
                    let title:String = buttonsToCreate[0]
                    buttonsToCreate[0] = "Begin Game"
                    let charArr:[Character] = [Character](title.characters)
                    let minNumber:Int = Int(String(charArr[0]))!
                    let upToFour:Bool = charArr.count == 2
                    
                    for i in 0..<(upToFour ? 4 : minNumber) {
                        let label:UILabel = UILabel()
                        label.text = "Player \(i + 1)"
                        label.font = UIFont.systemFontOfSize(40)
                        label.textColor = UIColor.whiteColor()
                        label.textAlignment = .Center
                        label.translatesAutoresizingMaskIntoConstraints = false
                        label.tag = i
                        vStack.insertArrangedSubview(label, atIndex: i)
                        
                        vStack.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(padding/2)-[label]-\(padding/2)-|", options: .AlignAllCenterX, metrics: nil, views: ["label":label]))
                        vStack.addConstraint(NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 90))
                    }
                }
                
                createButtonsWithNames(buttonsToCreate)
                animateButtonsIn()
            } else {
                // If going back to the top
                createButtonsWithNames([String](gamesOptions.keys).sort())
                animateButtonsIn()
                header.text = "Games"
            }
        }
    }
    
    private func animateButtonsIn() {
        for button in vStack.subviews {
            UIView.animateWithDuration(0.5, animations: {
                button.alpha = 1
            })
        }
    }
    
    private func animateButtonsOut() {
        for button in vStack.subviews {
            UIView.animateWithDuration(0.5, animations: {
                button.alpha = 0
                }, completion: {(completed:Bool) in
                    button.removeFromSuperview()
            })
        }
    }
    
    private func createButtonsWithNames(names:[String]) {
        for name in names {
            let button:UIButton = UIButton(type: .System)
            var setName = name
            if name.componentsSeparatedByString(":").count > 1 {
                setName = name.componentsSeparatedByString(":")[1]
            }
            button.setTitle(setName, forState: .Normal)
            button.addTarget(self, action: #selector(SideMenuView.buttonSelected(_:)), forControlEvents: .PrimaryActionTriggered)
            
            button.alpha = 0
            
            vStack.addArrangedSubview(button)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            vStack.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(padding/2)-[button]-\(padding/2)-|", options: .AlignAllCenterX, metrics: nil, views: ["button":button]))
            vStack.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 90))
        }
    }
    
    init() {
        super.init(frame: CGRectZero)
        
        self.backgroundColor = UIColor.blueColor()
        
        // Header
        header.text = "Games"
        header.font = UIFont.boldSystemFontOfSize(100)
        header.textAlignment = .Center
        header.textColor = UIColor.whiteColor()
        header.adjustsFontSizeToFitWidth = true
        self.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(padding/2)-[header]-\(padding/2)-|", options: .AlignAllCenterX, metrics: nil, views: ["header":header]))
        
        // Vertical Stackview for Options
        vStack.axis = .Vertical
        vStack.spacing = 10
        vStack.alignment = .Center
        vStack.distribution = .EqualSpacing
        
        self.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[vStack]|", options: .AlignAllCenterX, metrics: nil, views: ["vStack":vStack]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(padding/2)-[header]-\(padding/2)-[vStack]-\(padding)-|", options: .AlignAllCenterX, metrics: nil, views: ["header":header, "vStack":vStack]))
        
        createButtonsWithNames([String](gamesOptions.keys).sort())
        animateButtonsIn()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
