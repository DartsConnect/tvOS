//
//  CricketGame.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 31/03/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

class CricketGame: Game, GameDelegate {
    
    let validHits:[UInt] = [15,16,17,18,19,20,25]
    private var closedNumbers:[Int] =  []
    private var isCutThroat:Bool = false
    
    // Friday April 01 2016
    private func cutThroatDartHit(hitValue:UInt, multiplier:UInt) {
        
    }
    
    // Friday April 01 2016
    private func normalDartHit(hitValue:UInt, multiplier:UInt) {
        (players[currentTurn] as! CricketPlayer).didHitNumber(hitValue, multiplier: multiplier)
    }
    
    // Friday April 01 2016
    func delegateDartDidHit(hitValue: UInt, multiplier: UInt) {
        if validHits.contains(hitValue) {
            if isCutThroat {
                cutThroatDartHit(hitValue, multiplier: multiplier)
            } else {
                normalDartHit(hitValue, multiplier: multiplier)
            }
        }
    }
}
