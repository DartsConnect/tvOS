//
//  FreeGame.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 16/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

class WorldGame: Game, GameDelegate {
    let requiredAreasOrder:[UInt] = Array(1...20)
    
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
            descDict[player.user.username] = player.gameScores.allTurns.map {$0.numThrows}.reduce(0, combine: +)
        }
        let sortedDescDict = descDict.sort {$0.1 < $1.1}
        
        showGameSummaryWith("Around the World", sortedDescDict: sortedDescDict, prefix: "Number of throws")
    }
    
    /**
     Called when a dart hits the board
     Check if the section hit is the next number in the sequence
     Once a use hits 20, finish the player's game
     The Game superclass will handle ending the game when all of the players are finished
     
     - parameter dartHit: The dart hit data
     */
    func delegateDartDidHit(dartHit:DartHit) {
        let requiredNumber = UInt(players[currentTurn].score + 1)
        
        if dartHit.section == requiredNumber {
            players[currentTurn].score = Int(requiredNumber)
            if dartHit.section == 20 {
                playerFinished()
            }
        } else {
            gvc.scoresBar!.tacOutLastHit()
        }
    }
    
    init(gvc:GameViewController, users:[User]) {
        super.init(gameViewController: gvc)
        
        currentGame = self
        
        createStandardPlayers(users)
        
        gvc.addScoresSideBar()
    }
}
