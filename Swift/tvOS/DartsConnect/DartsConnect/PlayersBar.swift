//
//  PlayerBar.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 5/04/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class PlayerBarSection: UIView {
    var playerNameLabel:UILabel!
    var playerScoreLabel:UILabel!
    
    /**
     Reflect the Player's game play status as finished in the UI
     */
    func setFinishedGame() {
        self.backgroundColor = kColorGreen
    }
    
    /**
     Highlight the current player who should be throwing
     */
    func setCurrentPlayer() {
        self.backgroundColor = kColorBlue
    }
    
    /**
     Highlight the colour of a player that will throw next
     This is almost purely for debugging
     */
    func setWaitingPlayer() {
        if isDebugging {
            if self.backgroundColor != UIColor.orangeColor() {
                self.backgroundColor = UIColor.greenColor()
            }
        } else {
            if self.backgroundColor != kColorGreen {
                self.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    init(playerName:String, score:UInt) {
        super.init(frame: CGRectZero)
        
        self.backgroundColor = kColorBlack
        if isDebugging {self.backgroundColor = UIColor.greenColor()}
        
        // Create the player name label and customise it
        playerNameLabel = UILabel()
        playerNameLabel.text = playerName
        playerNameLabel.font = UIFont.systemFontOfSize(40)
        playerNameLabel.adjustsFontSizeToFitWidth = true
        playerNameLabel.textAlignment = .Center
        playerNameLabel.textColor = kColorWhite
        playerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(playerNameLabel)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[playerNameLabel]-10-|", options: .AlignAllCenterX, metrics: nil, views: ["playerNameLabel":playerNameLabel]))
        
        // Create the player score label and customise it
        playerScoreLabel = UILabel()
        playerScoreLabel.text = "\(score)"
        playerScoreLabel.font = UIFont.boldSystemFontOfSize(90)
        playerScoreLabel.adjustsFontSizeToFitWidth = true
        playerScoreLabel.textAlignment = .Center
        playerScoreLabel.textColor = kColorWhite
        playerScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(playerScoreLabel)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[playerScoreLabel]-10-|", options: .AlignAllCenterX, metrics: nil, views: ["playerScoreLabel":playerScoreLabel]))
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[playerScoreLabel(\(playerScoreLabel.font.pointSize))]-10-[playerNameLabel(\(playerNameLabel.font.pointSize + 10))]-15-|", options: .AlignAllCenterX, metrics: nil, views: ["playerScoreLabel":playerScoreLabel, "playerNameLabel":playerNameLabel]))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PlayersBar: UIView {
    var playersStack:UIStackView!
    var parentVC:UIViewController!
    let playerCount = GlobalVariables.sharedVariables.currentGame!.players.count
    let spacerAdj = GlobalVariables.sharedVariables.currentGame!.players.count <= 2 ? 1 : 0
    
    /**
     Adjusts the index for the spacer views
     
     - parameter index: The index of the player in a list of players
     
     - returns: The index of the player in a list of players with spacers on either side
     */
    func adjustedIndexFrom(index:Int) -> Int {
        return index + spacerAdj
    }
    
    /**
     Set the player's status to finished and reflect those changes visually
     
     - parameter index: The adjust index of the player
     */
    func setPlayerFinised(index:Int) {
        (playersStack.arrangedSubviews[adjustedIndexFrom(index)] as! PlayerBarSection).setFinishedGame()
    }
    
    /**
     Set the current player and the waiting player and reflect those changes visually
     */
    func setCurrentPlayer() {
        let game = GlobalVariables.sharedVariables.currentGame!
        (playersStack.arrangedSubviews[adjustedIndexFrom(game.previousTurn)] as! PlayerBarSection).setWaitingPlayer()
        (playersStack.arrangedSubviews[adjustedIndexFrom(game.currentTurn)] as! PlayerBarSection).setCurrentPlayer()
    }
    
    /**
     Update the score of a player to a new one
     
     - parameter index: Index of player in a list of players
     - parameter score: The new score for the player
     */
    func updatePlayerScore(index:Int, score:Int) {
        let spacerAdj = GlobalVariables.sharedVariables.currentGame?.players.count <= 2 ? 1 : 0
        let playerview = playersStack.arrangedSubviews[index + spacerAdj] as! PlayerBarSection
        playerview.playerScoreLabel.text = "\(score)"
    }
    
    /**
     Apply the constraints for each section in the horizontal player stack
     
     - parameter section: A member view of the stack
     */
    func applySectionConstraintsTo(section:UIView) {
        playersStack.addConstraint(NSLayoutConstraint(item: section, attribute: .Height, relatedBy: .Equal, toItem: playersStack, attribute: .Height, multiplier: 1, constant: -20))
        playersStack.addConstraint(NSLayoutConstraint(item: section, attribute: .CenterY, relatedBy: .Equal, toItem: playersStack, attribute: .CenterY, multiplier: 1, constant: 0))
        playersStack.addConstraint(NSLayoutConstraint(item: section, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 300))
    }
    
    /**
     A bit of a hack so that when there are only one or two players, their scores on the bottom bar are centered rather than out on the edges
     */
    func addSpacerView() {
        let spacer:UIView = UIView()
        spacer.backgroundColor = UIColor.clearColor()
        if isDebugging {spacer.backgroundColor = UIColor.greenColor()}
        playersStack.addArrangedSubview(spacer)
        
        spacer.translatesAutoresizingMaskIntoConstraints = false
        applySectionConstraintsTo(spacer)
    }
    
    init(parent:UIViewController, players:[String], startScore: UInt) {
        super.init(frame: CGRectZero)
        parentVC = parent
        
        self.backgroundColor = kColorBlack
        self.applyDropShadow()
        if isDebugging {self.backgroundColor = UIColor.redColor()}
        
        // Create a horizontal stackview to contain all of the player views
        playersStack = UIStackView()
        playersStack.axis = .Horizontal
        playersStack.spacing = 10
        playersStack.alignment = .Center
        playersStack.distribution = .EqualSpacing
        playersStack.translatesAutoresizingMaskIntoConstraints = false
        
        if players.count <= 2 { addSpacerView()}
        
        for playerName in players {//for i in 1...4 {
            let player:PlayerBarSection = PlayerBarSection(playerName: /*"Player \(i)"*/playerName, score: startScore)
            playersStack.addArrangedSubview(player)
            player.translatesAutoresizingMaskIntoConstraints = false
            applySectionConstraintsTo(player)
        }
        
        if players.count <= 2 { addSpacerView()}
        
        self.addSubview(playersStack)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-50-[playerStack]-50-|", options: .AlignAllCenterX, metrics: nil, views: ["playerStack":playersStack]))
        self.addConstraints(playersStack.fullVerticalConstraint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
