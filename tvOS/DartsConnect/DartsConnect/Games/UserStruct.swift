//
//  UserStruct.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 27/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

// MARK: User data
struct User { // Tuesday 24 May 2016
    var cardID:String!
    var username:String!
    var uid:String?
    var isGuest:Bool {
        get {
            return cardID.containsString("Guest")
        }
    }
    
    init(_ cid:String) {
        cardID = cid
        
        if isGuest {
            let numGuests = GlobalVariables.sharedVariables.currentGame!.players.filter {$0.user.isGuest}.count
            username = "Guest \(numGuests + 1)"
        } else {
            print("Get username")
            username = GlobalVariables.sharedVariables.dbManager.getUsernameForCardID(cardID)!
            print("Username done")
            print(username)
            if username == nil {
                username = "Not Registered"
            } else {
                uid = GlobalVariables.sharedVariables.dbManager.getUIDForCardID(cardID)!
            }
        }
    }
}

