//
//  Game.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 31/03/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

@objc protocol GameDelegate {
    optional func delegateBeginGame()
    optional func delegateEndGame()
    func delegateDartDidHit(hitValue:UInt, multiplier:UInt)
}

class Game: NSObject, ConnectorDelegate {
    var currentGame:GameDelegate?
    var currentTurn:Int = 0
    var currentRound:Int = 1
    var roundLimit:Int = -1
    var players:[Player] = []
    var gvc:GameViewController!
    
    func dartboardDidConnect() {
        
    }
    
    func dartboardKickedMeOff(reason: String) {
        
    }
    
    func dartboardDisconnected(error: NSError?) {
        
    }
    
    func playerNames() -> [String] {
        var playerNames:[String] = []
        for player in players {
            playerNames.append(player.username)
        }
        return playerNames
    }
    
    func getCurrentThrowNumber() -> Int {
        let ts = players[currentTurn].turnScores
        return ts.count
    }
    
    func dartDidHit(hitValue: UInt, multiplier: UInt) {
        if players[currentTurn].turnScores.count < 3 && players[currentTurn].canAcceptHit {
            gvc.showHitScore(hitValue * multiplier)
            gvc.scoresBar.showScore(hitValue, multiplier: multiplier)
            
            // The Player threw a dart
            if players[currentTurn].threwDart(hitValue, multiplier: multiplier) {
                //            self.nextPlayer()
                gvc.scoresBar.setButtonTitle(.Next)
            }
            
            currentGame!.delegateDartDidHit(hitValue, multiplier: multiplier)
        }
    }
    
    func changeToNextPlayer() {
        
        gvc.showHitScore("Next Player")
        
        gvc.scoresBar.resetScoresSidebar()
        gvc.scoresBar.setButtonTitle(.Skip)
        
        players[currentTurn].endTurn()
        
        currentTurn += 1
        currentTurn = currentTurn == players.count ? currentTurn - 1 : currentTurn
        while players[currentTurn].isFinished {
            if currentTurn == players.count {
                currentTurn = 0
                currentRound += 1
                
                if roundLimit != -1 && currentRound > roundLimit {
                    self.endGame()
                }
            }
            currentTurn += 1
        }
        players[currentTurn].canAcceptHit = true
        gvc.playerBar.setCurrentPlayer(currentTurn)
    }
    
    func playerFinished() {
        players[currentTurn].isFinished = true
        gvc.playerBar.setPlayerFinised(currentTurn)
        gvc.showHitScore("YOU WIN!")

        // Check if all the players are done.
        let isAllDone = !(players.map {$0.isFinished}.filter {!$0}.count > 0)
        if isAllDone {
            endGame()
        }
    }
    
    func beginGame() {
        gvc.playerBar.setCurrentPlayer(currentTurn)
    }
    
    func endGame() {
        gvc.returnToMainVC()
        print("Game has been finished")
    }
    
    func quitGame() {
        
    }

    init(gameViewController:GameViewController) {
        super.init()
        gvc = gameViewController
        GlobalVariables.sharedVariables.connector?.delegate = self
        GlobalVariables.sharedVariables.currentGame = self
    }
 
}
