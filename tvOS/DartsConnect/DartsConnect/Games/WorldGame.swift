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
    
    init(gvc:GameViewController, playerIDs:[String]) {
        super.init(gameViewController: gvc)
        
        currentGame = self
        
        createStandardPlayers(playerIDs)
        
        gvc.addScoresSideBar()
    }
}
