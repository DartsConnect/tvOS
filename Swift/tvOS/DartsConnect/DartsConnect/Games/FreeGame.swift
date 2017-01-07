//
//  FreeGame.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 16/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

class FreeGame: Game, GameDelegate {
    
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
        let sortedDescDict = descDict.sort {$0.1 > $1.1}
        
        showGameSummaryWith(gameType.title!, sortedDescDict: sortedDescDict, prefix: "Total Score")
    }
    
    /**
     Called when a dart hits the board
     Add to the current player's score
     When the round limit is reached, end the game
     
     - parameter dartHit: The dart hit data
     */
    func delegateDartDidHit(dartHit:DartHit) {
        let tHitValue:Int = Int(dartHit.totalHitValue)
        let cPlayerScore:Int = players[currentTurn].score
        players[currentTurn].score = cPlayerScore + tHitValue
        
        if currentTurn == players.count - 1{
            if players[currentTurn].turnScores.numThrows == 3 {
                if currentRound == roundLimit {
                    endGame()
                }
            }
        }
    }
    
    init(gameViewController: GameViewController, users:[User], numRounds:Int) {
        super.init(gameViewController: gameViewController)
        roundLimit = numRounds
        currentGame = self
        
        createStandardPlayers(users)
        
        gvc.addScoresSideBar()
    }
}