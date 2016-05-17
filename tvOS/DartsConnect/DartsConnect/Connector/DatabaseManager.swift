//
//  DatabaseManager.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 15/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

class DatabaseManager: NSObject {
    
    enum UserRegistrationError:ErrorType {
        case CardAlreadyRegistered
    }
    
    func registerCard(cardID:String, email:String, username:String) throws {
        
    }
    
    /*
     A stub.
     Will later be replaced with actual code to fetch the username of the user from the database based on the user's RFID card's UID.
     */
    /**
     Fetches the username of the user from the database with the cardID
     @param The CardID of the user
     @return The user's username
     */
    func getUsernameForCardID(cardID:String) -> String {
        enum Players:String {
            case Jordan = "00000000"
            case Jack = "00000001"
            case Will = "00000002"
            case Sam = "00000003"
            case Kimber = "00000004"
            
            var name:String {
                switch self {
                case .Jordan:
                    return "Jordan"
                case .Jack:
                    return "Jack"
                case .Will:
                    return "Will"
                case .Sam:
                    return "Sam"
                case .Kimber:
                    return "Kimber"
                }
            }
        }
        
        return Players(rawValue: cardID)!.name
    }
}