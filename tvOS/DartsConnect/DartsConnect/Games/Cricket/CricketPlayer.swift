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
    
    func getCut(hitValue:UInt, multiplier:UInt) {
        if !closedNumbers.contains(hitValue) {
            score += Int(hitValue * multiplier)
        }
    }
    
    // Friday April 01 2016
    private func registerScore(hitValue:UInt, multiplier:UInt) {
        if isCutThroat {
            (game as! CricketGame).cutThroatRegisterScore(self, hitValue: hitValue, multiplier: multiplier)
        } else {
            if !(game as! CricketGame).hasEveryPlayerClosed(hitValue) {
                score += Int(hitValue * multiplier)
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
    func didHitNumber(hitValue:UInt, multiplier:UInt) {
        if !closedNumbers.contains(hitValue) {
            // If the hit number is not yet closed
                        
            closureBuffer[hitValue] = closureBuffer[hitValue]! + multiplier
            (game as! CricketGame).updateCloseCountFor(self, number: hitValue, count: closureBuffer[hitValue]!)
            if closureBuffer[hitValue]! == 3 {
                closeNumber(hitValue)
            }
            
        } else if Int(closureBuffer[hitValue]! + multiplier) - 3 > 0 {
            // if the number is not yet closed, but will be with this shot with some extra
            // ie 15 was hit twice, and just got hit with a triple, meaning 2 shots will earn points
            
            let overflow:UInt = (closureBuffer[hitValue]! + multiplier) - 3
            closeNumber(hitValue)
            registerScore(hitValue, multiplier: overflow)
            (game as! CricketGame).updateCloseCountFor(self, number: hitValue, count: 3)
            
            
        } else { // If the hit number is closed
            registerScore(hitValue, multiplier: multiplier)
        }
    }
    
    // Friday April 01 2016
    init(_isCutThroat:Bool, _cardID:String) {
        super.init(_cardID: _cardID)
        
        isCutThroat = _isCutThroat
    }
}
