//
//  Game.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 31/03/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

protocol GameDelegate {
    func delegateDartDidHit(dartHit:DartHit)
}

class Game: NSObject, ConnectorDelegate {
    let timestamp:NSDate = NSDate()
    var currentGame:GameDelegate?
    var currentTurn:Int = 0
    var previousTurn:Int = 0
    var currentRound:Int = 1
    var roundLimit:Int = -1
    var players:[Player] = []
    var gvc:GameViewController!
    var saveData:[GameSaveData] = []
    var gameType:GameType!
    
    func dartboardDidConnect() {
        
    }
    
    func dartboardKickedMeOff(reason: String) {
        
    }
    
    func dartboardDisconnected(error: NSError?) {
        
    }
    
    func playerNames() -> [String] {
        var playerNames:[String] = []
        for player in players {
            playerNames.append(player.user.username)
        }
        return playerNames
    }
    
    func getCurrentThrowNumber() -> Int {
        let ts = players[currentTurn].turnScores
        return ts.numThrows
    }
    
    func dartDidHit(hitValue: UInt, multiplier: UInt) {
        let dartHit = DartHit(hitSection: hitValue, hitMultiplier: multiplier)
        if players[currentTurn].turnScores.numThrows < 3 && players[currentTurn].canAcceptHit {
            gvc.showHitScore(dartHit.totalHitValue)
            gvc.scoresBar?.showScore(dartHit)
            
            // The Player threw a dart
            if players[currentTurn].threwDart(dartHit) {
                //            self.nextPlayer()
                gvc.scoresBar?.setButtonTitle(.Next)
            }
            
            currentGame!.delegateDartDidHit(dartHit)
        }
    }
    
    func findNextTurn() {
        currentTurn += 1
        if currentTurn == players.count {
            currentTurn = 0
            currentRound += 1
            
            if roundLimit != -1 && currentRound > roundLimit {
                self.endGame()
            }
        }
        if players[currentTurn].isFinished {
            self.findNextTurn()
        }
    }
    
    func changeToNextPlayer() {
        
        gvc.showHitScore("Next Player")
        
        gvc.scoresBar?.resetScoresSidebar()
        gvc.scoresBar?.setButtonTitle(.Skip)
        
        players[currentTurn].endTurn()
        
        previousTurn = currentTurn
        
        self.findNextTurn()
        
        players[currentTurn].canAcceptHit = true
        gvc.playerBar.setCurrentPlayer()
    }
    
    func saveGame() {
        print("Start Saving Game")
        for player in players {
            if player.user.uid != nil {
                GameSaveData(
                    player: player,
                    aGameType: gameType,
                    thisGame:self,
                    aTimestamp: timestamp
                    ).pushToDatabase()
            }
        }
        print("Finish Saving Game")
    }
    
    func playerFinished() {
        players[currentTurn].isFinished = true
        players[currentTurn].canAcceptHit = false
        players[currentTurn].endTurn()
        gvc.playerBar.setPlayerFinised(currentTurn)
        gvc.showHitScore("YOU WIN!")
        
        // Check if all the players are done.
        let isAllDone = !(players.map {$0.isFinished}.filter {!$0}.count > 0)
        if isAllDone {
            endGame()
        }
    }
    
    func createStandardPlayers(playerIDs:[String]) {
        for playerID in playerIDs {
            players.append(Player(cardID: playerID))
        }
    }
    
    func beginGame() {
        gvc.playerBar.setCurrentPlayer()
    }
    
    func endGame() {
        print("Game has been finished")
        saveGame()
    }
    
    func showGameSummaryWith(title:String, playersDesc:[String:String], winnerOrder:[String]) {
        gvc.presentViewController(GameSummaryViewController(title: title, players: playersDesc, places: winnerOrder), animated: true, completion: nil)
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
