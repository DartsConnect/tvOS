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
    
    func updateCloseCountFor(player:CricketPlayer, number:UInt, count:UInt) {
        let index = players.indexOf(player)!
        gvc.cricketDisplay!.updateCloseStageFor(index, closeNumber: Int(number), toStage: Int(count))
    }
    
    func cutThroatRegisterScore(playerThatDealtIt:CricketPlayer, hitValue:UInt, multiplier:UInt) {
        for player in players where player != playerThatDealtIt {
            (player as! CricketPlayer).getCut(hitValue, multiplier: multiplier)
        }
    }
    
    // Friday April 01 2016
    func delegateDartDidHit(hitValue: UInt, multiplier: UInt) {
        if validHits.contains(hitValue) {
            (players[currentTurn] as! CricketPlayer).didHitNumber(hitValue, multiplier: multiplier)
        }
    }
    
    override func beginGame() {
        gvc.addScoresTopBar()
        gvc.addCricketCloseDisplay(players.count)
        super.beginGame()
    }
    
    init(gameViewController: GameViewController, cutThroat:Bool, playerIDs:[String]) {
        super.init(gameViewController: gameViewController)
        currentGame = self
        isCutThroat = cutThroat
        for playerID in playerIDs {
            players.append(CricketPlayer(_isCutThroat: isCutThroat, _cardID: playerID))
        }
    }
}
