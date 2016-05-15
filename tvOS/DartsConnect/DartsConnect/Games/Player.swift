//
//  Player.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 31/03/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

class Player: NSObject {
    var cardID:String = ""
    var username:String = ""
    var totalNumberOfThrows:UInt = 0
    var score:Int = 0 {
        didSet {
            let cg = GlobalVariables.sharedVariables.currentGame!
            if let index = cg.players.indexOf(self) {
                cg.gvc.playerBar.updatePlayerScore(index, score: score)
            }
        }
    }
    var turnScores:[(UInt,UInt)] = []
    var gameScores:[[(UInt, UInt)]] = []
    let game = GlobalVariables.sharedVariables.currentGame!
    var isFinished:Bool = false
    var canAcceptHit:Bool = true
    
    /*
     A stub.
     Will later be replaced with actual code to fetch the username of the user from the database based on the user's RFID card's UID.
    */
    /**
     Fetches the username of the user from the database with the cardID
     @param The CardID of the user
     @return The user's username
    */
    func getUserForCardID(cardID:String) -> String {
        return "Jordan"
    }
    
    /**
     Called when a player throws a dart and the hit was registered on the board.
     Each player only ever get 3 throws (valid hits) per turn.
     So it checks if the number of registered hits is 3 and returns false if true and true if false, so the game can decide whether or not it is time to switch players.
     It will then reset the current play throw count back to 0.
     
     @return Whether or not can throw again
    */
    func threwDart(hitValue:UInt, multiplier:UInt) -> Bool {
        totalNumberOfThrows += 1
        turnScores.append((hitValue, multiplier))
        return turnScores.count == 3
    }
    
    func getTurnSum() -> UInt {
        return turnScores.map {$0.0 * $0.1}.reduce(0, combine: +)
    }
    
    func endTurn() {
        
        /*
         This section of the function is overriden by its subclasses
         Once super is called, the following will run
        */
        
        gameScores.append(turnScores)
        turnScores = []
        print("Score \(score)")
    }
    
    func forceEndTurn(reason:ForceEndTurnReason) {
        canAcceptHit = false
        game.gvc.showHitScore(reason.description)
        self.endTurn()
    }
    
    init(_cardID:String) {
        super.init()
        cardID = _cardID;
        if cardID == "Guest" {
            username = "Guest"
        } else {
            username = getUserForCardID(cardID)
        }
    }
}
