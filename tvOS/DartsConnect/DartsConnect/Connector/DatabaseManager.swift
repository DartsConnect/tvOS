//
//  DatabaseManager.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 15/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation
import Firebase

class DatabaseManager: NSObject {
    
    var rootRef = Firebase(url: "https://dartsconnect.firebaseio.com")
    
    enum UserRegistrationError:ErrorType {
        case CardAlreadyRegistered
    }
    
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
     
     - author: Jordan Lewis
     - date: Wednesday 18 May 2016
     - parameters:
     - None
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
     
     - author: Jordan Lewis
     - date: Wednesday 18 May 2016
     - parameters:
        - None
     - returns: None
     - todo: None
    */
    func loginTo(email:String, password:String, completion:(error:NSError?, uid:String?) -> Void) {
        rootRef.authUser(email, password: password, withCompletionBlock: {
            error, authData in
            completion(error: error, uid: authData.uid)
        })
    }
    
    /**
     
     - author: Jordan Lewis
     - date: Thursday 19 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    func resetPasswordFor(email:String, tempPass:String, newPass:String, completion:(error:NSError?, uid:String?) -> Void) {
        rootRef.changePasswordForUser(email, fromOld: tempPass, toNew: newPass, withCompletionBlock: {
            error in
            if error == nil {
                self.rootRef.authUser(email, password: newPass, withCompletionBlock: {
                    error, authData in
                    completion(error: error, uid: authData.uid)
                })
            } else {
                completion(error: error, uid: nil)
            }
        })
    }
    
    /**
     
     - author: Jordan Lewis
     - date: Wednesday 18 May 2016
     - parameters:
        - None
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
     Queries the database to see if the username a user entered is already taken or not.
     Processing is done by Firebase.
     
     - author: Jordan Lewis
     - date: Wednesday 18 May 2016
     - parameters:
        - username: String containing a username that the user wants
     - returns: Bool, if the username is available or not.
     - todo: None
     */
    func isUsernameAvailable(username:String, completion:(isAvailable:Bool) -> Void) {
        let ref = rootRef.childByAppendingPath("usernames")
        
        ref.queryEqualToValue(username).observeSingleEventOfType(.Value, withBlock: {
            dataSnapshot in
            completion(isAvailable: dataSnapshot.value is NSNull)
        })
    }
    
    func isCardAlreadyRegistered(cardID:String, completion:(isAvailable:Bool) -> Void) {
        let ref = rootRef.childByAppendingPath("cardIDs")
        
        ref.queryEqualToValue(cardID).observeSingleEventOfType(.Value, withBlock: {
            dataSnapshot in
            completion(isAvailable: dataSnapshot.value is NSNull)
        })
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
    func OLDgetUsernameForCardID(cardID:String) -> String {
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
    
    /**
     
     - author: Jordan Lewis
     - date: Friday 20 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    func getUsernameForCardID(cardID:String, completion:(username:String) -> Void) {
        let cardtoUIDRef = rootRef.childByAppendingPath("cardID-UID/\(cardID)")
        
        cardtoUIDRef.observeSingleEventOfType(.Value, withBlock: {
            uidSnapshot in
            if uidSnapshot.value is NSNull {
                
            } else {
                let uid = uidSnapshot.value as! String
                let usernameRef = self.rootRef.childByAppendingPath("users/\(uid)/username")
                
                usernameRef.observeSingleEventOfType(.Value, withBlock: {
                    usernameSnapshot in
                    completion(username: usernameSnapshot.value as! String)
                })
            }
        })
    }
    
    override init() {
        super.init()
        
        rootRef.authAnonymouslyWithCompletionBlock({
            error, authData in
            if error == nil {
                print("Firebase authenticated anonymously")
            } else {
                print("Uh oh, Firebase failed to authenticate anonymously... what should I do? Here is the error message \(error!.description)")
            }
        })
    }
}