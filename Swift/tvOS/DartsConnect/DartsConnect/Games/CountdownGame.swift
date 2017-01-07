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
    var openCriteria:[GameEndsCriteria]!
    var closeCriteria:[GameEndsCriteria]!
    /**
     The status of a throw, whether it be normal, bust, or zero
     
     - Normal:           It was a normal hit and the score was counted
     - Open:             The hit met the game opening criteria
     - Close:            The hit met the game closing criteria
     - Bust:             The throw caused the player to bust
     - NotOpenCriteria:  The throw did not meet game opening criteria
     - NotCloseCriteria: The throw did not meet game ending criteria
     - author: Jordan Lewis
     - date: Friday May 06 2016
     - todo: N/A
     */
    enum ThrowStatus {
        case Normal
        case Open
        case Close // Win
        case Bust
        case NotOpenCriteria
        case NotCloseCriteria
    }
    
    /**
     Checks if a hit meets any of the criteria in an array of GameEndsCriteria
     
     - parameter criteria: An array of GameEndsCriteria to test against
     - parameter dartHit:  The dart hit to test
     - author: Jordan Lewis
     - date: Friday April 01 2016
     - todo: N/A
     - returns: True if it meets any, false if it doesn't meet
     */
    private func doesMeetCriteria(criteria:[GameEndsCriteria], dartHit:DartHit) -> Bool {
        if criteria.contains(.Any) { return true }
        if criteria.contains(.OnBull) && dartHit.section == 25 { return true }
        switch dartHit.multiplier {
        case 1:
            if criteria.contains(.OnSingle) { return true }
            break
        case 2:
            if criteria.contains(.OnDouble) || (criteria.contains(.OnDoubleBull) && dartHit.section == 25) { return true }
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
    
    /**
     Get the status of a throw
     
     - parameter dartHit: The throw to get the status of
     
     - returns: The status of the throw
     */
    func getThrowStatus(dartHit:DartHit) -> ThrowStatus {
        let cPlayerScore:Int = players[currentTurn].score
        let nPlayerScore:Int = cPlayerScore - Int(dartHit.totalHitValue)
        
        // If it is a shot to open the count down and there is a condition to open the game.
        if cPlayerScore == Int(gameStartScore) {
            if doesMeetCriteria(openCriteria, dartHit: dartHit) {
                return .Open
            } else {
                return .NotOpenCriteria
            }
        } else {
            // If the user Busts
            if nPlayerScore < 0 {
                return .Bust
            } else if nPlayerScore == 0 {
                if doesMeetCriteria(closeCriteria, dartHit: dartHit) {
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
        
        // If it didn't apply to any of the above, the throw must be normal.
        return .Normal
    }
    
    /**
     Called when a dart hits the board
     Get the throw status and act accordingly
     
     - parameter dartHit: The dart hit data
     - author: Jordan Lewis
     - date: Friday April 01 2016
     - todo: N/A
     */
    func delegateDartDidHit(dartHit:DartHit) {
        let cPlayerScore:Int = players[currentTurn].score
        
        switch getThrowStatus(dartHit) {
        case .Normal, .Open:
            players[currentTurn].score = cPlayerScore - Int(dartHit.totalHitValue)
            break
        case .Close:
            players[currentTurn].score = 0
            playerFinished()
            gvc.scoresBar!.setButtonTitle(ScoresSideBar.ActionButtonTitle.Next)
            break
        case .Bust:
            // When the player busts, the turn's throws don't count, so add them back
            let turnSum:Int = Int(players[currentTurn].turnScores.turnTotal)
            players[currentTurn].score = players[currentTurn].score + turnSum - Int(dartHit.totalHitValue)
            
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
    
    /**
     Called to end a game
     Do the Game superclass's end game code
     Then generate a dictionary of players and their places
     Finally, show the Game Summary Screen
     
     - author: Jordan Lewis
     - date: Monday 23 May 2016
     - returns: None
     - todo: None
     */
    override func endGame() {
        super.endGame()
        
        var descDict:[String:Int] = [:]
        for player in players  {
            //print(player.gameScores)
            if player.gameScores.allTurns.last!.numThrows < 3 {
                descDict[player.user.username] = ((player.gameScores.numTurns - 1) * 3) + player.gameScores.allTurns.last!.numThrows
            } else {
                descDict[player.user.username] = player.gameScores.numTurns * 3
            }
        }
        let sortedDescDict = descDict.sort {$0.1 < $1.1}
        
        showGameSummaryWith("\(gameStartScore)", sortedDescDict: sortedDescDict, prefix: "Throws taken to complete")
    }
    
    /**
     Initialise the Countdown Game
     
     - parameter gvc:        The game view controller
     - parameter startScore: The score to count down from
     - parameter users:      An array of users for the players
     - parameter openC:      An array of GameEndsCriteria
     - parameter closeC:     An array of GameEndsCriteria
     - author: Jordan Lewis
     - date: Friday April 01 2016
     - todo: N/A
     - returns: An initialised Countdown Game
     */
    init(gvc:GameViewController, startScore:UInt, users:[User], openC:[GameEndsCriteria], closeC:[GameEndsCriteria]) {
        super.init(gameViewController: gvc)
        
        openCriteria = openC
        closeCriteria = closeC
        
        gameStartScore = startScore
        
        currentGame = self
        
        createStandardPlayers(users)
        
        for player in players {
            player.score = Int(startScore)
        }
        
        gvc.addScoresSideBar()
    }
    
}
