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
    
    func setFinishedGame() {
        self.backgroundColor = UIColor.orangeColor()
    }
    
    func setCurrentPlayer() {
        print("Set Current Player")
        self.backgroundColor = UIColor.blueColor()
    }
    
    func setWaitingPlayer() {
        print("Set Waiting Player")
        self.backgroundColor = UIColor.greenColor()
    }
    
    init(playerName:String, score:UInt) {
        super.init(frame: CGRectZero)
        
        if isDebugging {self.backgroundColor = UIColor.greenColor()}
        
        playerNameLabel = UILabel()
        playerNameLabel.text = playerName
        playerNameLabel.font = UIFont.systemFontOfSize(40)
        playerNameLabel.adjustsFontSizeToFitWidth = true
        playerNameLabel.textAlignment = .Center
        playerNameLabel.textColor = UIColor.whiteColor()
        playerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(playerNameLabel)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[playerNameLabel]-10-|", options: .AlignAllCenterX, metrics: nil, views: ["playerNameLabel":playerNameLabel]))
        
        playerScoreLabel = UILabel()
        playerScoreLabel.text = "\(score)"
        playerScoreLabel.font = UIFont.boldSystemFontOfSize(90)
        playerScoreLabel.adjustsFontSizeToFitWidth = true
        playerScoreLabel.textAlignment = .Center
        playerScoreLabel.textColor = UIColor.whiteColor()
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
    
    func adjustedIndexFrom(index:Int) -> Int {
        return index + spacerAdj
    }
    
    func setPlayerFinised(index:Int) {
        (playersStack.arrangedSubviews[adjustedIndexFrom(index)] as! PlayerBarSection).setFinishedGame()
    }
    
    func setCurrentPlayer(index:Int) {
        (playersStack.arrangedSubviews[adjustedIndexFrom(index)] as! PlayerBarSection).setCurrentPlayer()
        if playerCount > 1 {
            let ppviAdj = playerCount <= 2 ? (index == 0 ? 1 : -1) : (index == 0 ? playerCount-1 : -1)
            (playersStack.arrangedSubviews[adjustedIndexFrom(index) - ppviAdj] as! PlayerBarSection).setWaitingPlayer()
        }
    }
    
    func updatePlayerScore(index:Int, score:Int) {
        let spacerAdj = GlobalVariables.sharedVariables.currentGame?.players.count <= 2 ? 1 : 0
        let playerview = playersStack.arrangedSubviews[index + spacerAdj] as! PlayerBarSection
        playerview.playerScoreLabel.text = "\(score)"
    }
    
    // A bit of a hack so that when there are only one or two players, their scores on the bottom bar are centered rather than out on the edges
    func addSpacerView() {
        let spacer:UIView = UIView()
        if isDebugging {spacer.backgroundColor = UIColor.greenColor()}
        playersStack.addArrangedSubview(spacer)
        
        spacer.translatesAutoresizingMaskIntoConstraints = false
        playersStack.addConstraint(NSLayoutConstraint(item: spacer, attribute: .Height, relatedBy: .Equal, toItem: playersStack, attribute: .Height, multiplier: 1, constant: -20))
        playersStack.addConstraint(NSLayoutConstraint(item: spacer, attribute: .CenterY, relatedBy: .Equal, toItem: playersStack, attribute: .CenterY, multiplier: 1, constant: 0))
        playersStack.addConstraint(NSLayoutConstraint(item: spacer, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 300))
    }
    
    init(parent:UIViewController, players:[String], startScore: UInt) {
        super.init(frame: CGRectZero)
        parentVC = parent
        
        if isDebugging {self.backgroundColor = UIColor.redColor()}
        
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
            playersStack.addConstraint(NSLayoutConstraint(item: player, attribute: .Height, relatedBy: .Equal, toItem: playersStack, attribute: .Height, multiplier: 1, constant: -20))
            playersStack.addConstraint(NSLayoutConstraint(item: player, attribute: .CenterY, relatedBy: .Equal, toItem: playersStack, attribute: .CenterY, multiplier: 1, constant: 0))
            playersStack.addConstraint(NSLayoutConstraint(item: player, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 300))
        }
        
        if players.count <= 2 { addSpacerView()}
        
        self.addSubview(playersStack)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-50-[playerStack]-50-|", options: .AlignAllCenterX, metrics: nil, views: ["playerStack":playersStack]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[playerStack]|", options: .AlignAllCenterY, metrics: nil, views: ["playerStack":playersStack]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
