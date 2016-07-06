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
    
    // Friday April 01 2016
    private func registerScore(dartHit:DartHit) {
        if isCutThroat {
            (game as! CricketGame).cutThroatRegisterScore(self, dartHit: dartHit)
        } else {
            if !(game as! CricketGame).hasEveryPlayerClosed(dartHit.section) {
                score += Int(dartHit.totalHitValue)
            }
        }
    }
    
    // Friday April 01 2016
    private func closeNumber(numToClose:UInt) {
        closedNumbers.append(numToClose)
        
        if closedNumbers.count == 7 {
            // TODO Complete game code
            // This player has finished the game
            
        }
    }
    
    // Friday April 01 2016
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
    
    // Friday April 01 2016
    init(_isCutThroat:Bool, cardID:String) {
        super.init(cardID: cardID)
        
        isCutThroat = _isCutThroat
    }
}
