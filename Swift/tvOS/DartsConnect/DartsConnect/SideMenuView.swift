//
//  SideMenuView.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 13/02/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class SideMenuView: UIView, BonjourManagerDelegate, ConnectorDelegate {
    
    // MARK: Variables
    // Sizing
    let width:CGFloat = 450
    let padding:CGFloat = 50
    
    // Other UI
    let header:UILabel = UILabel(frame: CGRectZero)
    
    // Options
    let vStack:UIStackView = UIStackView(frame: CGRectZero)
    
    /*
     *  This variable is a triple nested dictionary containing the menu structure for the side menu.
     *  The keys are the headings for each section, while the value (array) are all the available button options
     *  This could have probably been done better with structs, but its done and it works.
     *  Note to future Jordan: Change this to work in structs, this is ugly... Stupid, Stupid me. Much love from Friday 29 July 2016.
     */
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
        "3:\(GameClass.World.rawValue)":[
            "0:Add Players":["Player 1", "Player 2", "Player 3", "Player 4", "Begin Game"]
        ],
        "4:More":[
            "0:More":["Connect Board", "Create Account"],
        ]
    ]
    
    var breadcrumbs:[String] = [] // The path that the user has selected to reach the current menu
    var players:[String] = ["nil", "nil", "nil", "nil"] // The player names to play the game
    var users:[User?] = [nil, nil, nil, nil] // An array of users linked to the player names in the above array
    var cardIDtoUsername:[String:String] = [:] // A dictionary containing usernames to cardIDs
    var parentVC:UIViewController! // The view controller containing this side menu
    
    // MARK: Start Game
    /**
     Called when the Begin Game button is pressed
     Will make sure that there are enough players registered to play that game
     If not, it will prompt the user to fill in the required spots with Guests
     After verifying the right number of players,
     it will proceed to transitioning to the Game View Controller
     
     - author: Jordan Lewis
     - date: Friday April 29 2016
     - todo: N/A
     */
    func handleBeginGame() {
        if stripOrderNumbers(breadcrumbs)[0] == GameClass.Cricket.rawValue { // If the selected game is cricket
            if stripOrderNumbers(breadcrumbs)[1] == "Cut-Throat" { // and if the cricket game is Cut-Throat
                if self.removeNilPlayers(players).count < 2 { // and if there are less than two players
                    showNotEnoughPlayersAlert(2, gameTitle: "Cut-Throat Cricket") // prompt the user to fill it in with guests
                    return
                }
            }
        }
        
        if atLeastOnePlayer() {
            animateButtonsOut()
            // Show the Game View Controller
            parentVC.presentViewController(GameViewController(gameSettings: stripOrderNumbers(breadcrumbs), players: removeNilUsers(users)), animated: true, completion: nil)
        } else {
            // If no players are registered, prompt the user to play as a guest.
            showNotEnoughPlayersAlert(1, gameTitle: breadcrumbs.first!.componentsSeparatedByString(":")[1])
        }
    }
    
    /**
     Shows the add player alert when a player button is selected on the side menu.
     
     - parameter sender: The instance of UIButton that called this function
     - author: Jordan Lewis
     - date: Wednesday April 06 2016
     - todo: N/A
     */
    private func showAddPlayerAlert(sender:UIButton) {
        let alert = UIAlertController(title: "Player \(sender.tag + 1)", message: "Select Guest to play anonymously or Cancel and scan a card to play with your account.", preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Guest", style: .Default, handler: {
            (action:UIAlertAction) in
            let playerIndex:Int = Int(alert.title!.componentsSeparatedByString(" ")[1])!
            let cardID = "Guest \(sender.tag + 1)"
            self.players[playerIndex - 1] = cardID
            self.users[playerIndex - 1] = User(cardID: cardID, username: "Guest", uid: nil)
            sender.setTitle("Guest", forState: .Normal)
        }))
        
        alert.addAction(UIAlertAction(title: "Remove Player", style: .Default, handler: {
            (action:UIAlertAction) in
            let playerIndex:Int = Int(alert.title!.componentsSeparatedByString(" ")[1])!
            self.players[playerIndex - 1] = "nil"
            self.users[playerIndex - 1] = nil
            sender.setTitle("Player \(playerIndex)", forState: .Normal)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        parentVC.showViewController(alert, sender: nil)
    }
    
    /**
     A wrapper around a common funtional line to strip all of the 0: and 1: ... off of the selected options in the breadcrumbs.
     
     - parameter bc: Breadcrumbs
     
     - returns: Breadcrumbs with the order numbers / prefixes removed.
     */
    func stripOrderNumbers(bc:[String]) -> [String] {
        return bc.map {$0.componentsSeparatedByString(":")[1]}
    }
    
    /**
     Filters out/removes all the player's that weren't assigned to play a game.
     
     - parameter ps: A list of player names.
     
     - returns: A list of player names, with all nils removed.
     */
    func removeNilPlayers(ps:[String]) -> [String] {
        return ps.filter {$0 != "nil"}
    }
    
    /**
     Filters out/removes all of the users that weren't assigned to play a game.
     
     - parameter us: A list of users, possibly containing a nil user.
     
     - returns: A list of users, cleansed of any nils
     */
    func removeNilUsers(us:[User?]) -> [User] {
        var filtered:[User] = []
        for u in us{
            if u != nil {
                filtered.append(u!)
            }
        }
        return filtered
    }
    
    /**
     Checks whether or not there is at least one player registered to play the game.
     
     - returns: Boolean (True/False), if at least one, then True, and vice versa.
     */
    func atLeastOnePlayer() -> Bool {
        for p in players {
            if p != "nil" {
                return true
            }
        }
        return false
    }
    
    /**
     Show the not enough players alert to fill in the required number of players
     
     - parameter requiredPlayers: The number of required players.
     - parameter gameTitle:       The title of the game, to be used as a heading for the alert.
     */
    func showNotEnoughPlayersAlert(requiredPlayers:Int, gameTitle:String) {
        let currentNumPlayers = removeNilPlayers(players).count
        let title = currentNumPlayers == 0 ? "No Players" : "Not enough players." // Pick the correct title based on the number of players already registered
        // Select a conetextually correct prompt based on the number of required players.
        let actionPrompt = requiredPlayers == 1 ? "Select 'Play as Guest' to continue" : "Select 'Fill with Guest(s)' to fill the remaining required slots with guest players"
        // Generate a message based on some inputs
        let message = "\(gameTitle) requires \(requiredPlayers) player\(requiredPlayers > 1 ? "s":""). \(actionPrompt), or 'Back' to add other players."
        // Again, select a contextually correct prompt based on the number of required players.
        let actionTitle = requiredPlayers == 1 ? "Play as Guest" : "Fill with Guest(s)"
        
        let alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create action for filling in the required number of players
        alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: {
            (action:UIAlertAction) in
            if requiredPlayers == 1 { // If the required number of players is 1, we know that no players are registered, so just set the first one as a guest and continue.
                self.players[0] = "Guest"
                self.users[0] = User(cardID: "Guest", username: "Guest", uid: nil)
            } else {
                for _ in currentNumPlayers..<requiredPlayers { // Repeat however many times required to fill in the required number of players.
                    /*
                     If you're looking over this thinking, why did he use a nested loop and break out immediatly?
                     This simply finds the first nil player and replaces it for me
                     It's a bit hard to explain, but I thought this one through.
                     */
                    for i in 0..<self.players.count where self.players[i] == "nil" {
                        self.players[i] = "Guest"
                        self.users[i] = User(cardID: "Guest \(i)"/*For the sake of being unique*/, username: "Guest", uid: nil)
                        break
                    }
                }
            }
            self.animateButtonsOut()
            
            // Show the Game View Controller
            self.parentVC.presentViewController(GameViewController(gameSettings: self.stripOrderNumbers(self.breadcrumbs), players: self.removeNilUsers(self.users)), animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Back", style: .Default, handler: nil))
        
        // Present the Alert View Controller
        parentVC.showViewController(alert, sender: self)
    }
    
    // MARK: Navigation
    /**
     Return to the top of the menu.
     Also resets everything.
     */
    func returnToRoot() {
        if vStack.arrangedSubviews.count == 0 {
            breadcrumbs.removeAll()
            players = ["nil", "nil", "nil", "nil"]
            header.text = "Games"
            createRootButtons()
            animateButtonsIn()
        }
    }
    
    /**
     Called with any standard natvigation button selection.
     
     - parameter buttonsToCreate: The buttons to create after for the next menu. This is inout to allow for editting and assigning of the variable. Saves me from having to return and reassign it.
     - parameter sender:          The instance of the button that called this function.
     - parameter sub:             A list of sub heading for the game type being selected.
     - author: Jordan Lewis
     - date: Wednesday April 06 2016
     - todo: N/A
     */
    private func normalButtonSelectAction (inout buttonsToCreate:[String], sender:UIButton, sub:[String]) {
        animateButtonsOut()
        
        buttonsToCreate = gamesOptions[breadcrumbs[0]]![sub[breadcrumbs.count-1]]! // Access and assign the sub-menu options
        buttonsToCreate.append("Back") // Add the Back option
        
        // Assign the next heading based on the selected button.
        if breadcrumbs.count <= 1 && sender.currentTitle! != "Back" { // If the button pressed wasn't back, and our menu depth is <= 1
            if sub[breadcrumbs.count - 1] != "0:Type" { // and if the current heading is not the first/game type
                header.text = sub[breadcrumbs.count - 1].componentsSeparatedByString(":")[1] // Make the heading the next key, and strip the prefix
            } else { // if it isn't the first,
                header.text = sender.currentTitle! // set the next heading to the title of the button pressed
            }
        } else { // otherwise, based on the number of menu options deep, set the heading to the first, or the next one
            header.text = (breadcrumbs.count == 1 ? breadcrumbs[0]:sub[breadcrumbs.count - 1]).componentsSeparatedByString(":")[1]
        }
        
        createButtonsWithNames(buttonsToCreate)
        animateButtonsIn()
    }
    
    // Friday April 29 2016
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
            //parentVC.presentViewController(GameSummaryViewController(), animated: true, completion: nil)
            handleConnectDartBoard()
            break
        case "Create Account":
            parentVC.presentViewController(RegisterCardViewController(), animated: true, completion: nil)
            break
        default:
            handleStdNavigation(sender)
        }
    }
    
    // MARK: Bonjour and DartBoard Connection
    /**
     Called when a card is scanned and its Card ID is sent to the AppleTV
     This will query Firebase for the card owner's username and uid
     
     - parameter cardID: An 8 character alphanumeric string.
     */
    func cardScanned(cardID: String) {
        // Make sure that the current visible side menu section is the Add Players section
        if header.text == "Add Players" {
            GlobalVariables.sharedVariables.dbManager.getUsernameForCardID(cardID) {
                name in
                GlobalVariables.sharedVariables.dbManager.getUIDForCardID(cardID) {
                    uid in
                    let user = User(cardID: cardID, username: name, uid: uid)
                    
                    // Find the first nil player (open slot) and fill it in with the user who's card was scanned
                    for i in 0..<self.players.count {
                        if self.players[i] == "nil" {
                            self.players[i] = cardID
                            self.users[i] = user
                            self.cardIDtoUsername[cardID] = name
                            (self.vStack.arrangedSubviews[i] as! UIButton).setTitle(name, forState: .Normal)
                            break
                        }
                    }
                    
                    // If there were no nils, ie all taken
                    if !self.players.contains(cardID) {
                        // Create an alert, prompting the user to either pick a user to swap out, or cancel the card scan.
                        let alert = UIAlertController(title: "No Free Spots", message: "Select a player to swap out for \(name)", preferredStyle: .ActionSheet)
                        var usersDict:[String:String] = [:]
                        var guestsBindings:[String:String] = [:]
                        for player in self.players {
                            // If the player name does not contain the keyword "Guest", get his username and set that as the button title
                            var title = player.containsString("Guest") ? player : self.cardIDtoUsername[player]!
                            
                            usersDict[title] = player
                            
                            // Number the guests based on how many there are set to play the game.
                            if player.containsString("Guest") {
                                title = "Guest \(guestsBindings.count + 1)"
                                guestsBindings[title] = player
                            }
                            
                            // The action for swapping out the player for the card that was tapped
                            let action = UIAlertAction(title: title, style: .Default, handler: {
                                (action:UIAlertAction) in
                                var title = action.title!
                                if title.containsString("Guest") {
                                    title = guestsBindings[title]!
                                }
                                let id = usersDict[title]!
                                let index = self.players.indexOf(id)!
                                self.players[index] = cardID
                                self.users[index] = user
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
    }
    
    /**
     Called when the Connect to Dartboard button is pressed.
     Will initialise and assign a BonjourManager to a Global Variable, if it doesn't exist
     
     - author: Jordan Lewis
     - date: Friday April 29 2016
     - todo: N/A
     */
    func handleConnectDartBoard() {
        if GlobalVariables.sharedVariables.bonjourManager == nil {
            GlobalVariables.sharedVariables.bonjourManager = BonjourManager(self)
        }
    }
    
    /**
     This is here for the time being. I don't need it at the moment.
     
     - parameter serviceNames: A list of service names found by the BonjourManager
     - author: Jordan Lewis
     - date: Friday April 29 2016
     - todo: N/A
     */
    func bmFoundServices(serviceNames: [String]) {
        
    }
    
    // MARK: Button Work
    /**
     Animate all of the side menu's Buttons' alphas in.
     */
    private func animateButtonsIn() {
        for button in vStack.subviews {
            UIView.animateWithDuration(0.5, animations: {
                button.alpha = 1
            })
        }
    }
    
    /**
     Animate all of the side menu's Buttons' alphas out
     Upon completion, remove them from their superview.
     */
    private func animateButtonsOut() {
        for button in vStack.subviews {
            UIView.animateWithDuration(0.5, animations: {
                button.alpha = 0
                }, completion: {(completed:Bool) in
                    button.removeFromSuperview()
            })
        }
    }
    
    /**
     Create the inital game type selection buttons.
     Used for returning to the root/top of the menu.
     */
    private func createRootButtons() {
        createButtonsWithNames([String](gamesOptions.keys).sort())
    }
    
    /**
     Creates and adds buttons for every title/name in the array of the argument to the side menu button stack.
     
     - parameter names: A list of titles for buttons to be made and have.
     */
    private func createButtonsWithNames(names:[String]) {
        for name in names { // For every name in the array
            let button:UIButton = UIButton(type: .System) // Create a new button
            var setName = name
            if name.componentsSeparatedByString(":").count > 1 { // Just in case it has that order prefix, remove it.
                setName = name.componentsSeparatedByString(":")[1]
            }
            button.setTitle(setName, forState: .Normal) // Give it its name
            button.addTarget(self, action: #selector(SideMenuView.buttonSelected(_:)), forControlEvents: .PrimaryActionTriggered)
            
            button.alpha = 0 // Allow the buttons to be animated in.
            button.tag = names.indexOf(name)!
            
            vStack.addArrangedSubview(button) // Add it to the side menu vertical stack
            
            button.translatesAutoresizingMaskIntoConstraints = false
            // Horizontally center the button in the side menu
            vStack.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(padding/2)-[button]-\(padding/2)-|", options: .AlignAllCenterX, metrics: nil, views: ["button":button]))
            // Set the button's height to a constant 90
            vStack.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 90))
        }
    }
    
    /**
     Assigns self as the Bonjour Delegate to receive delegate calls
     */
    func assignSelfAsBonjourDelegate() {
        if GlobalVariables.sharedVariables.bonjourManager != nil {
            if GlobalVariables.sharedVariables.bonjourManager!.delegate == nil {
                GlobalVariables.sharedVariables.bonjourManager!.delegate = self
            }
        }
    }
    
    init(parent:UIViewController) {
        super.init(frame: CGRectZero)
        
        self.assignSelfAsBonjourDelegate()
        
        parentVC = parent
        self.backgroundColor = kColorBlack
        self.applyDropShadow()
        if isDebugging {self.backgroundColor = UIColor.blueColor()}
        
        // Header
        header.text = "Games"
        header.font = UIFont.boldSystemFontOfSize(100)
        header.textAlignment = .Center
        header.textColor = kColorBlue
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
