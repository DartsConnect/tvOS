//
//  SideMenuView.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 13/02/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class SideMenuView: UIView, BonjourManagerDelegate, ConnectorDelegate {
    
    // Sizing
    let width:CGFloat = 450
    let padding:CGFloat = 50
    
    // Other UI
    let header:UILabel = UILabel(frame: CGRectZero)
    
    // Options
    let vStack:UIStackView = UIStackView(frame: CGRectZero)
    let gamesOptions:[String:[String:[String]]] = [
        "0:\(GameClass.CountDown.rawValue)":[
            "0:Type":["301", "501", "701", "901", "1001"],
            "1:Open":[GameEndsCriteria.Any.rawValue, GameEndsCriteria.OnSingle.rawValue, GameEndsCriteria.OnDouble.rawValue, GameEndsCriteria.OnTriple.rawValue, GameEndsCriteria.OnBull.rawValue, GameEndsCriteria.OnDoubleBull.rawValue],
            "2:Close":[GameEndsCriteria.Any.rawValue, GameEndsCriteria.OnSingle.rawValue, GameEndsCriteria.OnDouble.rawValue, GameEndsCriteria.OnTriple.rawValue, GameEndsCriteria.OnBull.rawValue, GameEndsCriteria.OnDoubleBull.rawValue],
            "3:Add Players":["Player 1", "Player 2", "Player 3", "Player 4", "Begin Game"]
        ],
        "1:\(GameClass.Cricket.rawValue)":[
            "0:Type":["Cricket", "Cut-Throat"],
            "1:Add Players":["Player 1", "Player 2", "Player 3", "Player 4", "Begin Game"]
        ],
        "2:\(GameClass.Free.rawValue)":[
            "0:Rounds":["5", "10 ", "15"],
            "1:Add Players":["Player 1", "Player 2", "Player 3", "Player 4", "Begin Game"]
        ],
        "3:\(GameClass.TwentyToOne.rawValue)":[
            "0:Type":["Cricket", "Cut-Throat"],
            "1:Add Players":["Player 1", "Player 2", "Player 3", "Player 4", "Begin Game"]
        ],
        "4:\(GameClass.World.rawValue)":[
            "0:Add Players":["Player 1", "Player 2", "Player 3", "Player 4", "Begin Game"]
        ],
        "5:More":[
            "0:More":["Connect Board", "Create Account"],
        ]
        
    ]
    var breadcrumbs:[String] = []
    var players:[String] = ["nil", "nil", "nil", "nil"]
    var cardIDtoUsername:[String:String] = [:]
    var parentVC:UIViewController!
    
    
    func cardScanned(cardID: String) {
        if header.text == "Add Players" {
            
            GlobalVariables.sharedVariables.dbManager.getUsernameForCardID(cardID) {
                name in
                for i in 0..<self.players.count {
                    if self.players[i] == "nil" {
                        self.players[i] = cardID
                        self.cardIDtoUsername[cardID] = name
                        (self.vStack.arrangedSubviews[i] as! UIButton).setTitle(name, forState: .Normal)
                        break
                    }
                }
                
                // If there were no nils, ie all taken
                if !self.players.contains(cardID) {
                    let alert = UIAlertController(title: "No Free Spots", message: "Select a player to swap out for \(name)", preferredStyle: .ActionSheet)
                    var usersDict:[String:String] = [:]
                    var guestsBindings:[String:String] = [:]
                    for player in self.players {
                        var title = player.containsString("Guest") ? player : self.cardIDtoUsername[player]!
                        
                        usersDict[title] = player
                        
                        if player.containsString("Guest") {
                            title = "Guest \(guestsBindings.count + 1)"
                            guestsBindings[title] = player
                        }
                        
                        let action = UIAlertAction(title: title, style: .Default, handler: {
                            (action:UIAlertAction) in
                            var title = action.title!
                            if title.containsString("Guest") {
                                title = guestsBindings[title]!
                            }
                            let id = usersDict[title]!
                            let index = self.players.indexOf(id)!
                            self.players[index] = cardID
                            (self.vStack.arrangedSubviews[index] as! UIButton).setTitle(name, forState: .Normal)
                        })
                        alert.addAction(action)
                    }
                    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    self.parentVC.showViewController(alert, sender: nil)
                }
            }
        }
    }
    
    func returnToRoot() {
        if vStack.arrangedSubviews.count == 0 {
            breadcrumbs.removeAll()
            players = ["nil", "nil", "nil", "nil"]
            header.text = "Games"
            createRootButtons()
            animateButtonsIn()
        }
    }
    
    // Wednesday April 06 2016
    private func normalButtonSelectAction (inout buttonsToCreate:[String], sender:UIButton, sub:[String]) {
        animateButtonsOut()
        
        buttonsToCreate = gamesOptions[breadcrumbs[0]]![sub[breadcrumbs.count-1]]!
        buttonsToCreate.append("Back")
        
        if breadcrumbs.count <= 1 && sender.currentTitle! != "Back" {
            if sub[breadcrumbs.count - 1] != "0:Type" {
                header.text = sub[breadcrumbs.count - 1].componentsSeparatedByString(":")[1]
            } else {
                header.text = sender.currentTitle!
            }
        } else {
            header.text = (breadcrumbs.count == 1 ? breadcrumbs[0]:sub[breadcrumbs.count - 1]).componentsSeparatedByString(":")[1]
        }
        
        createButtonsWithNames(buttonsToCreate)
        animateButtonsIn()
    }
    
    // Wednesday April 06 2016
    private func showAddPlayerAlert(sender:UIButton) {
        let alert = UIAlertController(title: "Player \(sender.tag + 1)", message: "Select Guest to play anonymously or Cancel and scan a card to play with your account.", preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Guest", style: .Default, handler: {
            (action:UIAlertAction) in
            let playerIndex:Int = Int(alert.title!.componentsSeparatedByString(" ")[1])!
            self.players[playerIndex - 1] = "Guest \(sender.tag + 1)"
            sender.setTitle("Guest", forState: .Normal)
        }))
        
        alert.addAction(UIAlertAction(title: "Remove Player", style: .Default, handler: {
            (action:UIAlertAction) in
            let playerIndex:Int = Int(alert.title!.componentsSeparatedByString(" ")[1])!
            self.players[playerIndex - 1] = "nil"
            sender.setTitle("Player \(playerIndex)", forState: .Normal)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
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
    
    
    func showNotEnoughPlayersAlert(requiredPlayers:Int, gameTitle:String) {
        let currentNumPlayers = removeNilPlayers(players).count
        let title = currentNumPlayers == 0 ? "No Players" : "Not enough players."
        let actionPrompt = requiredPlayers == 1 ? "Select 'Play as Guest' to continue" : "Select 'Fill with Guest(s)' to fill the remaining required slots with guest players"
        let message = "\(gameTitle) requires \(requiredPlayers) player\(requiredPlayers > 1 ? "s":""). \(actionPrompt), or 'Back' to add other players."
        let actionTitle = requiredPlayers == 1 ? "Play as Guest" : "Fill with Guest(s)"
        
        let alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: {
            (action:UIAlertAction) in
            if requiredPlayers == 1 {
                self.players[0] = "Guest"
            } else {
                for _ in currentNumPlayers..<requiredPlayers {
                    /*
                     If you're looking over this thinking, why did he use a nested loop and break out immediatly?
                     This simply finds the first nil player and replaces it for me
                     It's a bit hard to explain, but I though ths one through.
                    */
                    for i in 0..<self.players.count where self.players[i] == "nil" {
                        self.players[i] = "Guest"
                        break
                    }
                }
            }
            self.animateButtonsOut()
            self.parentVC.presentViewController(GameViewController(gameSettings: self.stripOrderNumbers(self.breadcrumbs), players: self.removeNilPlayers(self.players)), animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Back", style: .Default, handler: nil))
        parentVC.showViewController(alert, sender: self)
    }
    
    // Friday April 29 2016
    func handleBeginGame() {
        if stripOrderNumbers(breadcrumbs)[0] == GameClass.Cricket.rawValue {
            if stripOrderNumbers(breadcrumbs)[1] == "Cut-Throat" {
                if self.removeNilPlayers(players).count < 2 {
                    showNotEnoughPlayersAlert(2, gameTitle: "Cut-Throat Cricket")
                    return
                }
            }
        }
        
        if atLeastOnePlayer() {
            animateButtonsOut()
            parentVC.presentViewController(GameViewController(
                gameSettings: stripOrderNumbers(breadcrumbs),
                players: removeNilPlayers(players)),
                                           animated: true,
                                           completion: nil)
        } else {
            showNotEnoughPlayersAlert(1, gameTitle: breadcrumbs.first!.componentsSeparatedByString(":")[1])
        }
    }
    
    // Friday April 29 2016
    func handleConnectDartBoard() {
        if GlobalVariables.sharedVariables.bonjourManager == nil {
            GlobalVariables.sharedVariables.bonjourManager = BonjourManager(self)
        }
    }
    
    func doStdNaviagtion(sender:UIButton) {
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
    
    // Friday April 29 2016
    func handleStdNavigation(sender:UIButton) {
        var canNavigate = false
        if sender.currentTitle! == "More" {
            canNavigate = true
        } else {
            if GlobalVariables.sharedVariables.connector != nil {
                if GlobalVariables.sharedVariables.connector!.dataSocket.isConnected {
                    canNavigate = true
                    GlobalVariables.sharedVariables.connector!.delegate = self
                }
            }
        }
        
        if canNavigate {
            doStdNaviagtion(sender)
        } else {
            // Prompt connect to dartboard
            let alert = UIAlertController(title: "Connect to a Dartboard", message: "You must connect to a dartboard before continuing.", preferredStyle: .ActionSheet)
            let connectAction = UIAlertAction(title: "Connect", style: .Default, handler: {
                (action:UIAlertAction) in
                GlobalVariables.sharedVariables.bonjourManager = BonjourManager(nil)
            })
            alert.addAction(connectAction)
            parentVC.showViewController(alert, sender: nil)
        }
    }
    
    func buttonSelected(sender:UIButton) {
        switch sender.currentTitle! {
        case "Begin Game":
            handleBeginGame()
            break
        case "Connect Board":
            parentVC.presentViewController(GameSummaryViewController(), animated: true, completion: nil)
//            handleConnectDartBoard()
            break
        case "Create Account":
            parentVC.presentViewController(RegisterCardViewController(), animated: true, completion: nil)
            break
        default:
            handleStdNavigation(sender)
        }
    }
    
    
    
    // Friday April 29 2016
    func bmFoundServices(serviceNames: [String]) {
        
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
            button.tag = names.indexOf(name)!
            
            vStack.addArrangedSubview(button)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            vStack.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(padding/2)-[button]-\(padding/2)-|", options: .AlignAllCenterX, metrics: nil, views: ["button":button]))
            vStack.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 90))
        }
    }
    
    private func createRootButtons() {
        createButtonsWithNames([String](gamesOptions.keys).sort())
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
        self.addConstraints(vStack.fullHorizontalConstraint)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(padding/2)-[header]-\(padding/2)-[vStack]-\(padding)-|", options: .AlignAllCenterX, metrics: nil, views: ["header":header, "vStack":vStack]))
        
        createRootButtons()
        animateButtonsIn()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
