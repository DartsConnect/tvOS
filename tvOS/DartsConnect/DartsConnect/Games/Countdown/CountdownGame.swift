//
//  CountdownGame.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 31/03/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

class CountdownGame: Game, GameDelegate {
    
    enum GameEndsCriteria {
        case Any
        case OnSingle
        case OnDouble
        case OnTriple
        case OnBull
        case OnDoubleBull
    }
    
    private var gameStartScore:UInt = 0;
    private var openCriteria:[GameEndsCriteria] = []
    private var closeCriteria:[GameEndsCriteria] = []
    
    // Friday April 01 2016
    private func doesMeetCriteria(criteria:[GameEndsCriteria], hitValue:UInt, multiplier:UInt) -> Bool {
        if criteria.contains(.Any) { return true }
        if criteria.contains(.OnBull) && hitValue == 25 { return true }
        switch multiplier {
        case 1:
            if criteria.contains(.OnSingle) { return true }
            break
        case 2:
            if criteria.contains(.OnDouble) || (criteria.contains(.OnDoubleBull) && hitValue == 25) { return true }
            break
        case 3:
            if criteria.contains(.OnTriple) { return true }
            break
        default:
            print("I think something has gone wrong in the function doesMeetCriteria in CountdownGame.swift")
            return false
        }
        return false;
    }
    
    // Friday April 01 2016
    func delegateDartDidHit(hitValue: UInt, multiplier: UInt) {
        let tHitValue:Int = Int(hitValue * multiplier)
        var cPlayerScore:Int = players[currentTurn].score
        
        // If it is a shot to open the count down and there is a condition to open the game.
        if UInt(cPlayerScore) == gameStartScore {
            if doesMeetCriteria(openCriteria, hitValue: hitValue, multiplier: multiplier) {
                cPlayerScore -= tHitValue
                players[currentTurn].score = cPlayerScore
            }
        } else {
            players[currentTurn].score -= tHitValue
            
            // If the user Busts
            if cPlayerScore < 0 {
                cPlayerScore += tHitValue
                players[currentTurn].score = cPlayerScore
                players[currentTurn].forceEndTurn()
                nextPlayer()
            } else if cPlayerScore == 0 {
                if doesMeetCriteria(closeCriteria, hitValue: hitValue, multiplier: multiplier) {
                    // NOW the user finally wins
                } else {
                    // The player didn't hit the right spot to win according to the game conditions.
                    cPlayerScore += tHitValue
                    players[currentTurn].score = cPlayerScore
                    players[currentTurn].forceEndTurn()
                    nextPlayer()
                }
            }
        }
    }
    
    // Friday April 01 2016
    init(startScore:UInt, numPlayers:UInt) {
        super.init()

        gameStartScore = startScore
        
        currentGame = self
        
        for _ in 1...numPlayers {
            players.append(CountdownPlayer(startScore: startScore, cardID: ""))
        }
    }
    
}
