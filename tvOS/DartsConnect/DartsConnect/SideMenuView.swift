//
//  SideMenuView.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 13/02/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class SideMenuView: UIView, BonjourManagerDelegate {
    
    // Sizing
    let width:CGFloat = 450
    let padding:CGFloat = 50
    
    // Other UI
    let header:UILabel = UILabel(frame: CGRectZero)
    
    // Options
    let vStack:UIStackView = UIStackView(frame: CGRectZero)
    let gamesOptions:[String:[String:[String]]] = [
        "0:\(GameType.CountDown.rawValue)":[
            "0:Type":["301", "501", "701", "901", "1001"],
            "1:Open":[GameEndsCriteria.Any.rawValue, GameEndsCriteria.OnSingle.rawValue, GameEndsCriteria.OnDouble.rawValue, GameEndsCriteria.OnTriple.rawValue, GameEndsCriteria.OnBull.rawValue, GameEndsCriteria.OnDoubleBull.rawValue],
            "2:Close":[GameEndsCriteria.Any.rawValue, GameEndsCriteria.OnSingle.rawValue, GameEndsCriteria.OnDouble.rawValue, GameEndsCriteria.OnTriple.rawValue, GameEndsCriteria.OnBull.rawValue, GameEndsCriteria.OnDoubleBull.rawValue],
            "3:Add Players":["Player 1", "Player 2", "Player 3", "Player 4", "Begin Game"]
        ],
        "1:\(GameType.Cricket.rawValue)":[
            "0:Type":["Cricket", "Cut-Throat"],
            "1:Add Players":["Player 1", "Player 2", "Player 3", "Player 4", "Begin Game"]
        ],
        "2:\(GameType.Free.rawValue)":[
            "0:Type":["Cricket", "Cut-Throat"],
            "1:Add Players":["Player 1", "Player 2", "Player 3", "Player 4", "Begin Game"]
        ],
        "3:\(GameType.TwentyToOne.rawValue)":[
            "0:Type":["Cricket", "Cut-Throat"],
            "1:Add Players":["Player 1", "Player 2", "Player 3", "Player 4", "Begin Game"]
        ],
        "4:\(GameType.World.rawValue)":[
            "0:Type":["Cricket", "Cut-Throat"],
            "1:Add Players":["Player 1", "Player 2", "Player 3", "Player 4", "Begin Game"]
        ],
        "5:More":[
            "0:More":["Connect Board"],
        ]
        
    ]
    var breadcrumbs:[String] = []
    var players:[String] = ["nil", "nil", "nil", "nil"]
    var parentVC:UIViewController!
    
    
    // Wednesday April 06 2016
    private func normalButtonSelectAction (inout buttonsToCreate:[String], sender:UIButton, sub:[String]) {
        animateButtonsOut()
        
        buttonsToCreate = gamesOptions[breadcrumbs[0]]![sub[breadcrumbs.count-1]]!
        buttonsToCreate.append("Back")
        
        if breadcrumbs.count <= 1 && sender.currentTitle! != "Back" {
            header.text = sender.currentTitle!
        } else {
            header.text = (breadcrumbs.count == 1 ? breadcrumbs[0]:sub[breadcrumbs.count - 1]).componentsSeparatedByString(":")[1]
        }
        
        createButtonsWithNames(buttonsToCreate)
        animateButtonsIn()
    }
    
    // Wednesday April 06 2016
    private func showAddPlayerAlert(sender:UIButton) {
        let alert = UIAlertController(title: sender.currentTitle!, message: "Select Scan Card to play as you, or Guest to play anonymously.", preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Scan Card", style: .Default, handler: {
            (action:UIAlertAction) in
            let playerIndex:Int = Int(alert.title!.componentsSeparatedByString(" ")[1])!
            // Wait for Card to be scanned
            self.players[playerIndex] = "00000000"
        }))
        alert.addAction(UIAlertAction(title: "Guest", style: .Default, handler: {
            (action:UIAlertAction) in
            let playerIndex:Int = Int(alert.title!.componentsSeparatedByString(" ")[1])!
            self.players[playerIndex] = "Guest"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (action:UIAlertAction) in
            
        }))
        parentVC.showViewController(alert, sender: nil)
    }
    
    func stripOrderNumbers(bc:[String]) -> [String] {
        return bc.map {$0.componentsSeparatedByString(":")[1]}
    }
    
    func removeNilPlayers(ps:[String]) -> [String] {
        return ps.filter {$0 != "nil"}
    }
    
    func atLeastOnePlayer() -> Bool {
        for p in players {
            if p != "nil" {
                return true
            }
        }
        return false
    }
    
    // Friday April 29 2016
    func handleBeginGame() {
        if atLeastOnePlayer() {
            animateButtonsOut()
            parentVC.presentViewController(GameViewController(
                gameSettings: stripOrderNumbers(breadcrumbs),
                players: removeNilPlayers(players)),
                                           animated: true,
                                           completion: nil)
        } else {
            let alert:UIAlertController = UIAlertController(title: "No Players", message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Play as Guest", style: .Default, handler: {
                (action:UIAlertAction) in
                self.players[0] = "Guest"
                self.animateButtonsOut()
                self.parentVC.presentViewController(GameViewController(gameSettings: self.stripOrderNumbers(self.breadcrumbs), players: self.removeNilPlayers(self.players)), animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Back", style: .Default, handler: {
                (action:UIAlertAction) in
                
            }))
            parentVC.showViewController(alert, sender: self)
        }
    }
    
    // Friday April 29 2016
    func bmFoundServices(serviceNames: [String]) {
        
    }
    
    // Friday April 29 2016
    func handleConnectDartBoard() {
        if GlobalVariables.sharedVariables.bonjourManager == nil {
            GlobalVariables.sharedVariables.bonjourManager = BonjourManager(self)
        }
    }
    
    // Friday April 29 2016
    func handleStdNavigation(sender:UIButton) {
        let index = vStack.subviews.indexOf(sender)!
        let originalName = "\(index):\(sender.currentTitle!)"
        var buttonsToCreate:[String] = []
        
        if sender.currentTitle! == "Back" {
            breadcrumbs.popLast()
        } else {
            if header.text != "Add Players" {
                breadcrumbs.append(originalName)
            }
        }
        
        if breadcrumbs.count > 0 {
            let sub = [String](gamesOptions[breadcrumbs[0]]!.keys).sort()
            
            if header.text == "Add Players" {
                if sender.currentTitle! != "Back" {
                    showAddPlayerAlert(sender)
                } else {
                    normalButtonSelectAction(&buttonsToCreate, sender: sender, sub: sub)
                }
            } else {
                normalButtonSelectAction(&buttonsToCreate, sender: sender, sub: sub)
            }
        } else {
            animateButtonsOut()
            
            // If going back to the top
            createButtonsWithNames([String](gamesOptions.keys).sort())
            animateButtonsIn()
            header.text = "Games"
        }
    }
    
    func buttonSelected(sender:UIButton) {
        switch sender.currentTitle! {
        case "Begin Game":
            handleBeginGame()
            break
        case "Connect Board":
            handleConnectDartBoard()
            break
        default:
            handleStdNavigation(sender)
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
    
    init(parent:UIViewController) {
        super.init(frame: CGRectZero)
        
        parentVC = parent
        if isDebugging {self.backgroundColor = UIColor.blueColor()}
        
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
