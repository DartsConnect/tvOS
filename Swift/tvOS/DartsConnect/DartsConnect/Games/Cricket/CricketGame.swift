//
//  CricketGame.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 31/03/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

class CricketGame: Game, GameDelegate {
    
    let validHits:[UInt] = [15,16,17,18,19,20,25]
    private var closedNumbers:[Int] =  []
    var isCutThroat:Bool = false
    
    /**
     Checks if every player has closed a certain section
     
     - parameter number: The section to check if everyone has closed
     
     - returns: True if everyone has closed, otherwise false
     */
    func hasEveryPlayerClosed(number:UInt) -> Bool {
        return (players as! [CricketPlayer]).filter {$0.closedNumbers.contains(number)}.count == 0
    }
    
    /**
     Update the close stage for a player
     
     - parameter player: The player to have their close stage updated
     - parameter number: The section to be updated
     - parameter count:  How many the section should be updated by
     */
    func updateCloseCountFor(player:CricketPlayer, number:UInt, count:UInt) {
        let index = players.indexOf(player)!
        gvc.cricketDisplay!.updateCloseStageFor(index, closeNumber: Int(number), toStage: Int(count))
    }
    
    /**
     Cut all the players in the game except for the player that dealt it
     
     - parameter playerThatDealtIt: The Cricket Player that dealt the cut
     - parameter dartHit:           The dart hit that will cut the players
     */
    func cutThroatRegisterScore(playerThatDealtIt:CricketPlayer, dartHit:DartHit) {
        for player in players where player != playerThatDealtIt { // For every player except the one that dealt it
            let cricketPlayer = (player as! CricketPlayer)
            if cricketPlayer.getCut(dartHit, by: playerThatDealtIt) { // If the player got cut
                
                // Update the player that dealt it's stats
                if let amount = playerThatDealtIt.amountCut[cricketPlayer] {
                    playerThatDealtIt.amountCut[cricketPlayer] = amount + dartHit.totalHitValue
                } else {
                    playerThatDealtIt.amountCut[cricketPlayer] = dartHit.totalHitValue
                }
                
            }
        }
    }
    
    /**
     Called when the dart hits the dartboard
     Validates whether it was in one of the seven sections,
     if it is, tell the player's instance didHitNumber to process the hit
     
     - parameter dartHit: The dart hit data
     - author: Jordan Lewis
     - date: Friday April 01 2016
     - todo: N/A
     */
    func delegateDartDidHit(dartHit:DartHit) {
        if validHits.contains(dartHit.section) {
            (players[currentTurn] as! CricketPlayer).didHitNumber(dartHit)
        }
    }
    
    /**
     Overridden beginGame function to add a top scores bar and cricket close display
     */
    override func beginGame() {
        gvc.addScoresTopBar()
        gvc.addCricketCloseDisplay(players.count)
        super.beginGame()
    }
    
    /**
     Called to end a game
     Do the Game superclass's end game code
     Then generate a dictionary of players and their places
     Finally, show the Game Summary Screen
     */
    override func endGame() {
        super.endGame()
        
        var descDict:[String:Int] = [:]
        for player in players {
            descDict[player.user.username] = player.score
        }
        
        let sortedDescDict = isCutThroat ? descDict.sort {$0.1 < $1.1} : descDict.sort {$0.1 > $1.1}
        
        showGameSummaryWith(gameType.title!, sortedDescDict: sortedDescDict, prefix: "Score")
    }
    
    init(gameViewController: GameViewController, cutThroat:Bool, users:[User]) {
        super.init(gameViewController: gameViewController)
        currentGame = self
        isCutThroat = cutThroat
        
        // Create a Cricket Player for each user going to play the game
        for user in users {
            players.append(CricketPlayer(_isCutThroat: isCutThroat, user: user))
        }
    }
}
