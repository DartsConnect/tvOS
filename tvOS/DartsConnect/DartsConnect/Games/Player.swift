//
//  Player.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 31/03/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

class Player: NSObject {
    var user:User!
    var totalNumberOfThrows:UInt = 0
    var turnScores:DartTurn = DartTurn()
    var gameScores:DartGame = DartGame()
    let game = GlobalVariables.sharedVariables.currentGame!
    var isFinished:Bool = false
    var canAcceptHit:Bool = true
    var score:Int = 0 {
        didSet {
            let cg = game
            if let index = cg.players.indexOf(self) {
                if cg.gvc.playerBar != nil {
                    cg.gvc.playerBar.updatePlayerScore(index, score: score)
                }
            }
        }
    }

    /**
     Called when a player throws a dart and the hit was registered on the board.
     Each player only ever get 3 throws (valid hits) per turn.
     So it checks if the number of registered hits is 3 and returns false if true and true if false, so the game can decide whether or not it is time to switch players.
     It will then reset the current play throw count back to 0.
     
     @return Whether or not can throw again
    */
    func threwDart(dartHit:DartHit) -> Bool {
        totalNumberOfThrows += 1
        turnScores.addThrow(dartHit)
        return turnScores.numThrows == 3
    }
    
    func endTurn() {
        
        /*
         This section of the function is overriden by its subclasses
         Once super is called, the following will run
        */
        
        gameScores.addTurn(turnScores)
        
        turnScores = DartTurn()
        print("Score \(score)")
    }
    
    func forceEndTurn(reason:ForceEndTurnReason) {
        canAcceptHit = false
        game.gvc.showHitScore(reason.description)
        self.endTurn()
    }
    
    init(cardID:String) {
        super.init()
        user = User(cardID)
    }
}
