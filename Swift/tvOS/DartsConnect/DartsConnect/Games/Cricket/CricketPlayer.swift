//
//  CricketPlayer.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 31/03/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

class CricketPlayer: Player {
    var closedNumbers:[UInt] = []
    var closureBuffer:[UInt:UInt] = [
        15:0,
        16:0,
        17:0,
        18:0,
        19:0,
        20:0,
        25:0,
        ]
    var isCutThroat:Bool = false
    var amountCut:[CricketPlayer:UInt] = [:]
    var gotCutBy:[CricketPlayer:UInt] = [:]
    
    /**
     Called when the player gets cut by another player
     
     - parameter dartHit: The dart hit that cut this player
     - parameter by:      The player cutting this player
     
     - returns: A boolean reflecting whether this player successfully got cut
     */
    func getCut(dartHit:DartHit, by:CricketPlayer) -> Bool {
        if !closedNumbers.contains(dartHit.section) {
            score += Int(dartHit.totalHitValue)
            
            if let allCut = gotCutBy[by] {
                gotCutBy[by] = allCut + dartHit.totalHitValue
            } else {
                gotCutBy[by] = dartHit.totalHitValue
            }
            
            return true
        }
        return false
    }
    
    /**
     Register a dart hit score
     Checks if the game is cut-throat, if it is, then tell the game to cut all the other players
     Otherwise, as long as not all the other players have closed the section that was hit, add it to this player's score
     
     - parameter dartHit: The dart hit to be registered
     - author: Jordan Lewis
     - date: Friday April 01 2016
     - todo: N/A
     */
    private func registerScore(dartHit:DartHit) {
        if isCutThroat {
            (game as! CricketGame).cutThroatRegisterScore(self, dartHit: dartHit)
        } else {
            if !(game as! CricketGame).hasEveryPlayerClosed(dartHit.section) {
                score += Int(dartHit.totalHitValue)
            }
        }
    }
    
    /**
     Called when a number is going to be closed
     If 7 numbers are now closed, flag the player as finished,
     then game will handle when to finish the game based on if all players are finished or not
     
     - parameter numToClose: The section to close
     - author: Jordan Lewis
     - date: Friday April 01 2016
     - todo: N/A
     */
    private func closeNumber(numToClose:UInt) {
        closedNumbers.append(numToClose)
        
        if closedNumbers.count == 7 {
            // TODO Complete game code... I think this is done
            // This player has finished the game
            (GlobalVariables.sharedVariables.currentGame as! CricketGame).playerFinished()
        }
    }
    
    /**
     Called when a dart hits the dartboard
     Handles closing sections and regitering scores
     Takes into account overflows, ie 18 was hit 2x, and then a triple was hit, so 18*2 was registered as a score
     
     - parameter dartHit: The dart hit data
     - author: Jordan Lewis
     - date: Friday April 01 2016
     - todo: N/A
     */
    func didHitNumber(dartHit:DartHit) {
        if !closedNumbers.contains(dartHit.section) {
            // If the hit number is not yet closed
            
            closureBuffer[dartHit.section] = closureBuffer[dartHit.section]! + dartHit.multiplier
            (game as! CricketGame).updateCloseCountFor(self, number: dartHit.section, count: closureBuffer[dartHit.section]!)
            if closureBuffer[dartHit.section]! == 3 {
                closeNumber(dartHit.section)
            }
            
        } else if Int(closureBuffer[dartHit.section]! + dartHit.multiplier) - 3 > 0 {
            // if the number is not yet closed, but will be with this shot with some extra
            // ie 15 was hit twice, and just got hit with a triple, meaning 2 shots will earn points
            
            let overflow:UInt = (closureBuffer[dartHit.section]! + dartHit.multiplier) - 3
            closeNumber(dartHit.section)
            registerScore(DartHit(hitSection: dartHit.section, hitMultiplier: overflow))
            (game as! CricketGame).updateCloseCountFor(self, number: dartHit.section, count: 3)
            
            
        } else { // If the hit number is closed
            registerScore(dartHit)
        }
    }
    
    /// Friday April 01 2016
    init(_isCutThroat:Bool, user:User) {
        super.init(user)
        
        isCutThroat = _isCutThroat
    }
}
