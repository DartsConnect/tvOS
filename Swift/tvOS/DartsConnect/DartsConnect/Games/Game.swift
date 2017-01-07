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
    // MARK: Variables
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
    
    // MARK: Connector Delegate
    func dartboardDidConnect() {
        
    }
    
    func dartboardKickedMeOff(reason: String) {
        
    }
    
    func dartboardDisconnected(error: NSError?) {
        
    }
    
    /**
     Called when a dart hits the dartboard
     Converts the arguments into a DartHit
     Checks if the player can still accpet hits
     Then shows the score on the screen and shows the score
     Also tell the player to do whatever with the DartHit by calling player.threwDart
     
     - parameter hitValue:   The hit section
     - parameter multiplier: The multiplier hit
     */
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
    
    // MARK: Player Code
    /**
     Gets a list of player names from the players playing
     
     - returns: An array of strings containing all the player's names
     */
    func playerNames() -> [String] {
        var playerNames:[String] = []
        for player in players {
            playerNames.append(player.user.username)
        }
        return playerNames
    }
    
    /**
     Change turns and move to the next player
     */
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
    
    /**
     Flag a player as finished
     If all the players are done. End the game.
     */
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
    
    /**
     Find the next turn by considering who is finished, and looping around to the start, etc.
     Modifies the currentTurn variable
     */
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
    
    /**
     Get the current turn's current throw number
     
     - returns: The current turn's current throw number
     */
    func getCurrentThrowNumber() -> Int {
        let ts = players[currentTurn].turnScores
        return ts.numThrows
    }
    
    
    
    // MARK: Begin Game Code
    /**
     Create an array of standard Player instances from an array of Users
     
     - parameter users: An array of Users to play the game
     */
    func createStandardPlayers(users:[User]) {
        for user in users {
            players.append(Player(user))
        }
    }
    
    /**
     Start the game by assigning the current player to the first player
     */
    func beginGame() {
        gvc.playerBar.setCurrentPlayer()
    }
    
    // MARK: End Game Code
    /**
     Save the game data for every player in the game
     */
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
    
    /**
     End and save the game
     This is overriden and extended by Game subclasses to show the Game Summary Screen
     */
    func endGame() {
        print("Game has been finished")
        saveGame()
    }
    
    /**
     Show the game summary view controller
     
     - parameter title:          The title of the game summary view controller
     - parameter sortedDescDict: The sorted description dictionary, to be the information displayed
     - parameter prefix:         The prefix before the scores
     */
    func showGameSummaryWith(title:String, sortedDescDict:[(String, Int)], prefix:String) {
        var finalDescDict:[String:String] = [:]
        for (name, score) in sortedDescDict {
            finalDescDict[name] = "\(prefix): \(score)"
        }
        let places = sortedDescDict.map {$0.0}
        
        gvc.presentViewController(GameSummaryViewController(title: title, players: finalDescDict, places: places), animated: true, completion: nil)
    }
    
    /**
     NOT IMPLEMENTED
     Quit the game without saving.
     */
    func quitGame() {
        
    }
    
    // MARK: Initialiser
    init(gameViewController:GameViewController) {
        super.init()
        gvc = gameViewController
        GlobalVariables.sharedVariables.connector?.delegate = self
        GlobalVariables.sharedVariables.currentGame = self
    }
    
}
