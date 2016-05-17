//
//  FreeGame.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 16/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

class FreeGame: Game, GameDelegate {
    
    func delegateDartDidHit(hitValue: UInt, multiplier: UInt) {
        let tHitValue:Int = Int(hitValue * multiplier)
        let cPlayerScore:Int = players[currentTurn].score
        players[currentTurn].score = cPlayerScore + tHitValue
        
        if currentTurn == players.count - 1{
            if players[currentTurn].turnScores.count == 3 {
                if currentRound == roundLimit {
                    endGame()
                }
            }
        }
    }
    
    init(gameViewController: GameViewController, playerIDs:[String], numRounds:Int) {
        super.init(gameViewController: gameViewController)
        roundLimit = numRounds
        currentGame = self

        createStandardPlayers(playerIDs)
        
        gvc.addScoresSideBar()
    }
}
