//
//  CountdownGame.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 31/03/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

class CountdownGame: Game, GameDelegate {
    
    var gameStartScore:UInt = 0;
    private var openCriteria:[GameEndsCriteria]!
    private var closeCriteria:[GameEndsCriteria]!
    
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
    
    // Friday May 06 2016
    enum ThrowStatus {
        case Normal
        case Open
        case Close // Win
        case Bust
        case NotOpenCriteria
        case NotCloseCriteria
    }
    
    func getThrowStatus(hitValue: UInt, multiplier: UInt) -> ThrowStatus {
        let tHitValue:Int = Int(hitValue * multiplier)
        let cPlayerScore:Int = players[currentTurn].score
        let nPlayerScore:Int = cPlayerScore - tHitValue
        
        // If it is a shot to open the count down and there is a condition to open the game.
        if cPlayerScore == Int(gameStartScore) {
            if doesMeetCriteria(openCriteria, hitValue: hitValue, multiplier: multiplier) {
                return .Open
            } else {
                return .NotOpenCriteria
            }
        } else {
            // If the user Busts
            if nPlayerScore < 0 {
                return .Bust
            } else if nPlayerScore == 0 {
                if doesMeetCriteria(closeCriteria, hitValue: hitValue, multiplier: multiplier) {
                    // NOW the user finally wins
                    return .Close
                } else {
                    // The player didn't hit the right spot to win according to the game conditions.
                    return .NotCloseCriteria
                }
            }
        }
        
        // So that if there is a close criteria and the player goes below the lowest possible value, it will bust him. Otherwise he/she won't be able to finsih the game.
        if !closeCriteria.contains(.OnSingle) || !closeCriteria.contains(.Any) {
            var canCloseArr:[Bool] = []
            for criteria in closeCriteria {
                var canClose:Bool = true
                switch criteria {
                case .OnDouble:
                    if nPlayerScore < 2 {canClose = false}
                    break
                case .OnTriple:
                    if nPlayerScore < 3 {canClose = false}
                    break
                case .OnBull:
                    if nPlayerScore < 25 {canClose = false}
                    break
                case .OnDoubleBull:
                    if nPlayerScore < 50 {canClose = false}
                    break
                default:
                    break
                }
                canCloseArr.append(canClose)
            }
            return canCloseArr.contains(true) ? .Normal : .Bust
        }
        
        return .Normal
    }
    
    // Friday April 01 2016
    func delegateDartDidHit(hitValue: UInt, multiplier: UInt) {
        let tHitValue:Int = Int(hitValue * multiplier)
        let cPlayerScore:Int = players[currentTurn].score
        
        switch getThrowStatus(hitValue, multiplier: multiplier) {
        case .Normal, .Open:
            players[currentTurn].score = cPlayerScore - tHitValue
            break
        case .Close:
            players[currentTurn].score = 0
            playerFinished()
            gvc.scoresBar!.setButtonTitle(ScoresSideBar.ActionButtonTitle.Next)
            break
        case .Bust:
            // When the player busts, the turn's throws don't count, so add them back
            let turnSum:Int = Int(players[currentTurn].getTurnSum())
            players[currentTurn].score = players[currentTurn].score + turnSum - tHitValue
            
            gvc.scoresBar!.tacOutLastHit()
            
            players[currentTurn].forceEndTurn(.Bust)
            gvc.scoresBar!.setButtonTitle(ScoresSideBar.ActionButtonTitle.Next)
            break
        case .NotOpenCriteria:
            gvc.showHitScore(ForceEndTurnReason.OpenOn(criteria: openCriteria.first!).description)
            gvc.scoresBar!.tacOutLastHit()
            break
        case .NotCloseCriteria:
            players[currentTurn].forceEndTurn(.CloseOn(criteria: closeCriteria.first!))
            gvc.scoresBar!.tacOutLastHit()
            break
        }
    }
    
    // Friday April 01 2016
    init(gvc:GameViewController, startScore:UInt, playerIDs:[String], openC:[GameEndsCriteria], closeC:[GameEndsCriteria]) {
        super.init(gameViewController: gvc)
        
        openCriteria = openC
        closeCriteria = closeC
        
        gameStartScore = startScore
        
        currentGame = self
        
        createStandardPlayers(playerIDs)
        
        for player in players {
            player.score = Int(startScore)
        }
        
        gvc.addScoresSideBar()
    }
    
}
