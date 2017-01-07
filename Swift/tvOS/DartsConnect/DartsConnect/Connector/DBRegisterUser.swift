//
//  DBRegisterUser.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 7/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation
import Firebase

// MARK: - Register User
extension DatabaseManager {
    
    /**
     Generates a random password between 8 and 16 characters long
     Characters are a~z, A~Z, 0~9
     
     - author: Jordan Lewis
     - date: Wednesday 18 May 2016
     - returns: A string containing a password with lenght between 8 and 16 characters.
     */
    func generateRandomPassword() -> String {
        let lower = "abcdefghijklmnopqrstuvwxyz".characters.map {"\($0)"}
        let upper = lower.map { $0.uppercaseString }
        let numbers = "0123456789".characters.map {"\($0)"}
        let allChars = lower + upper + numbers
        let length = Int(arc4random_uniform(16) + 8)
        var pass = ""
        for _ in 0..<length {
            let char = allChars[Int(arc4random_uniform(UInt32(allChars.count)))]
            pass += char
        }
        return pass
    }
    
    /**
     Begin account creation by creating an account
     
     - author: Jordan Lewis
     - date: Wednesday 18 May 2016
     - parameter email:      The email address given to begin account creation
     - parameter completion: A completion containg an optional string, reflecting the success of the beginning of account creation
     - returns: None
     - todo: None
     */
    func beginAccountCreation(email:String, completion:(errorStr:String?) -> Void) {
        rootRef.createUser(email, password: generateRandomPassword(), withCompletionBlock: {
            error in
            if error == nil {
                self.rootRef.resetPasswordForUser(email, withCompletionBlock: {
                    error2 in
                    if error2 == nil {
                        completion(errorStr: nil)
                    } else {
                        completion(errorStr: "Failed to send verification email.")
                        print(error2.description)
                    }
                })
            } else {
                completion(errorStr: "Failed to create account.")
                print(error.description)
            }
        })
    }
    
    /**
     Register a card to the account being created.
     
     - author: Jordan Lewis
     - date: Wednesday 18 May 2016
     - parameter cardID:   The card ID to be registered
     - parameter uid:      The UID of the account to have the card registered to
     - parameter email:    The email address of the account being created
     - parameter username: The username of the account being created.
     - returns: None
     - todo: None
     */
    func registerCard(cardID:String, uid:String, email:String, username:String) {
        let usersRef = rootRef.childByAppendingPath("users")
        let cardIDtoUIDRef = rootRef.childByAppendingPath("cardID-UID")
        let cardIDsRef = rootRef.childByAppendingPath("cardIDs").childByAutoId()
        let usernamesRef = rootRef.childByAppendingPath("usernames").childByAutoId()
        
        let usersDict = ["email":email, "username":username, "cardID":cardID]
        usersRef.updateChildValues([uid:usersDict])
        
        cardIDtoUIDRef.updateChildValues([cardID:uid])
        
        cardIDsRef.setValue(cardID)
        
        usernamesRef.setValue(username)
    }
    
    /**
     Check if a card has been registered or not
     
     - parameter cardID:     The card ID to check
     - parameter completion: A completion callback containing a boolean value reflecting the status of whether or not the card has been registered
     */
    func isCardAlreadyRegistered(cardID:String, completion:(isAvailable:Bool) -> Void) {
        let ref = rootRef.childByAppendingPath("cardIDs")
        
        ref.queryEqualToValue(cardID).observeSingleEventOfType(.Value, withBlock: {
            dataSnapshot in
            completion(isAvailable: dataSnapshot.value is NSNull)
        })
    }
    
}