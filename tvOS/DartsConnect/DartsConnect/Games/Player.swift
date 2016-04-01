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
    var score:Int = 0
    var numThrowsInTurn:UInt = 0
    
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
    func threwDart() -> Bool {
        numThrowsInTurn += 1
        totalNumberOfThrows += 1
        if numThrowsInTurn == 3 {
            numThrowsInTurn = 0
            return false
        }
        return true
    }
    
    func forceEndTurn() {
        numThrowsInTurn = 0
    }
    
    init(_cardID:String) {
        super.init()
        cardID = _cardID;
        username = getUserForCardID(cardID)
        
    }
}
