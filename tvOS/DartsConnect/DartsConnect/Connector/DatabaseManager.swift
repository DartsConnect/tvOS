//
//  DatabaseManager.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 15/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation
import Firebase

struct DatabaseManager {
    let rootRef = Firebase(url: "https://dartsconnect.firebaseio.com")
    
    enum UserRegistrationError:ErrorType {
        case CardAlreadyRegistered
    }
    
    init() {
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

// MARK: Account Creation
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
}

// MARK: More Account Stuff
extension DatabaseManager {
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
}

// MARK: Fetching Data
extension DatabaseManager {
    /**
     
     - author: Jordan Lewis
     - date: Tuesday 24 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    func getUIDForCardID(cardID:String, completion:((uid:String) -> Void)? = nil) -> String? {
        let cardIDtoUIDPath = "cardID-UID/\(cardID)"
        if completion == nil {
            return self.getDataWithPath(cardIDtoUIDPath) as? String
        } else {
            self.getDataWithPath(cardIDtoUIDPath) {
                data in
                completion!(uid:data as! String)
            }
        }
        return nil
    }
    
    /**
     
     - author: Jordan Lewis
     - date: Tuesday 24 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    func getDataWithPath(path:String, completion:((data:AnyObject?) -> Void)? = nil) -> AnyObject? {
        let ref = rootRef.childByAppendingPath(path)
        return getDataFromReference(ref, completion: completion)
    }
    
    /**
     
     - author: Jordan Lewis
     - date: Wednesday 06 July 2016
     - parameters:
     - None
     - returns: None
     - todo: DOCUMENT THIS
     */
    func getDataFromReference(ref:Firebase, completion:((data:AnyObject?) -> Void)? = nil) -> AnyObject? {
        var semaphore:dispatch_semaphore_t?
        var data:AnyObject?
        if completion == nil {
            semaphore = dispatch_semaphore_create(0)
        }
        ref.observeSingleEventOfType(.Value, withBlock: {
            dataSnapshot in
            let value = dataSnapshot.value
            if completion == nil {
                data = value
                dispatch_semaphore_signal(semaphore!)
            } else {
                completion!(data: value)
            }
        })
        if completion == nil {
            dispatch_semaphore_wait(semaphore!, DISPATCH_TIME_FOREVER)
        }
        return data
    }
    
    /**
     
     - author: Jordan Lewis
     - date: Friday 20 May 2016, Rewritten Tuesday 24 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    func getUsernameForCardID(cardID:String, completion:((username:String) -> Void)? = nil) -> String? {
        var username:String?
        var sema:dispatch_semaphore_t?
        if completion == nil {
            sema = dispatch_semaphore_create(0)
        }
        getDataWithPath("cardID-UID/\(cardID)") {
            uidData in
            self.getDataWithPath("users/\(uidData as! String)/username") {
                usernameData in
                let unwrapped = usernameData as! String
                if completion == nil {
                    username = unwrapped
                    dispatch_semaphore_signal(sema!)
                } else {
                    completion!(username: unwrapped)
                }
                
            }
        }
        if completion == nil {
            dispatch_semaphore_wait(sema!, DISPATCH_TIME_FOREVER)
        }
        return username
    }
}

// MARK: Saving Game Data
extension DatabaseManager {
    /**
     Turns the NSDate into Unix Epoch time in a string
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameters:
     - None
     - returns: None
     - todo: DOCUMENT THIS
     */
    func formattedDateString(timestamp:NSDate) -> String {
        return "\(timestamp.timeIntervalSince1970)"
    }
    
    /**
     This function gets called when saving game data
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameters:
     - None
     - returns: None
     - todo: Update analytics
     */
    func saveGameData(saveData:GameSaveData) {
        let playDataRef = rootRef.childByAppendingPath("playData/\(saveData.user.uid!)")
        
        updateGamesLookupDict(playDataRef, gameType: saveData.gameType, timestamp: saveData.timestamp)
        writeGameData(playDataRef, timestamp: saveData.timestamp, dataDict: saveData.dataDict)
        updateAchievementsLookup(playDataRef, saveData: saveData)
        updateAllTimeAnalytics(playDataRef, saveData: saveData)
    }
    
    /**
     Adds the game being saved to the look up dictionary
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    private func updateGamesLookupDict(playDataRef:Firebase, gameType:GameType, timestamp:NSDate) {
        let gamesLookupRef = playDataRef.childByAppendingPath("gamesLookup").childByAutoId()
        gamesLookupRef.updateChildValues(
            [
                "gameType":gameType.title,
                "timestamp":formattedDateString(timestamp)
            ]
        )
    }
    
    /**
     Saved the game into the user's dictionary
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameters:
     - None
     - returns: None
     - todo: DOCUMENT THIS
     */
    private func writeGameData(playDataRef:Firebase, timestamp:NSDate, dataDict:[String:AnyObject]) {
        let gamesRef = playDataRef.childByAppendingPath("games/\(formattedDateString(timestamp))")
        gamesRef.setValue(dataDict)
    }
    
    /**
     Updates the achievements lookup dictionary
     
     - author: Jordan Lewis
     - date: Saturday 28 May 2016
     - parameters:
     - None
     - returns: None
     - todo: DOCUMENT THIS
     */
    private func updateAchievementsLookup(playDataRef:Firebase, saveData:GameSaveData) {
        let uid = saveData.user.uid!
        let achievements = saveData.dataDict["achievements"] as! [String:String]
        let newAch = achievements.mapValues {Achievement(longName: $1)!.shortName} // Convert the acheivement long names to short names
        
        let allAchTypes:[Achievement] = [.Ton80, .HighTon, .LowTon, .HatTrick, .HatTrickLT, .HatTrickHT, .ThreeInABed, .ThreeInTheBlack]
        
        /*
         For every type of achievement
         make an array of achievements of that type
         if there are achievements of that type
         get the current total of that achievement being achieved
         if there is some, add onto it and overwrite the current value
         if there isn't set the count of the filtered achievements to that value
         then add it into the games dictionary
         
         Look for about lines 44 to 54 in structure JSON
         playData -> uid -> achievements
         */
        for achType in allAchTypes {
            let filteredAch = newAch.filter {$1 == achType.shortName}
            let achPath = "achievements/\(achType.shortName)"
            let achRef = playDataRef.childByAppendingPath(achPath)
            if filteredAch.count > 0 {
                getDataWithPath("playData/\(uid)/achievements/\(achType.shortName)/numTimes") {
                    data in
                    if let num:Int = data as? Int {
                        achRef.childByAppendingPath("numTimes").setValue(filteredAch.count + num)
                    } else {
                        achRef.childByAppendingPath("numTimes").setValue(filteredAch.count)
                    }
                }
                
                achRef.childByAppendingPath("games").updateChildValues([
                    formattedDateString(saveData.timestamp):Array(filteredAch.keys)
                    ])
            }
        }
    }
    
    /**
     
     
     
     Look for:
     playData -> uid -> analytics
     
     - author: Jordan Lewis
     - date: Saturday 28 May 2016, Wednesday 06 July 2016
     - parameters:
     - None
     - returns: None
     - todo: DOCUMENT THIS, Complete this section of code
     */
    private func updateAllTimeAnalytics(playDataRef:Firebase, saveData:GameSaveData) {
        
        let analyticsRef = playDataRef.childByAppendingPath("analytics")
        let cricketRef = analyticsRef.childByAppendingPath("cricket")
        if saveData.gameType.gameClass == .Cricket {
            // If cricket, update the amount of points scored on self and others
            if saveData.gameType.title == GameType.Cricket(cutThroat: true).title {
                // If is cut-throat
                let cutThroatStats = cricketRef.childByAppendingPath("cut-throat")
                
                let scores = saveData.dataDict["cut-throat scores"] as! [String:[String:Int]]
                let onOthers = scores["onOthers"]!
                let tMe = saveData.dataDict["scores"] as! Int
                let tOthers = Array(onOthers.values).reduce(0, combine: +)
                
                getDataFromReference(cutThroatStats) {
                    data in
                    if data == nil {
                        cutThroatStats.setValue([
                            "onMe":tMe,
                            "onOthers":tOthers
                            ])
                    } else {
                        let dbOnMe = data!["onMe"] as! Int
                        let dbOnOthers = data!["onOthers"] as! Int
                        cutThroatStats.setValue([
                            "onMe":dbOnMe + tMe,
                            "onOthers":dbOnOthers + tOthers
                            ])
                    }
                }
                
                
            } else {
                // If normal cricket
                let cricketScoredRef = cricketRef.childByAppendingPath("normal/scored")
                let scored = saveData.dataDict["score"] as! Int
                getDataFromReference(cricketRef) {
                    data in
                    if data == nil {
                        cricketScoredRef.setValue(scored)
                    } else {
                        cricketScoredRef.setValue(data as! Int + scored)
                    }
                }
            }
        }
        
        // For every game, update the lifetime hit distribution table
        /*
         get the current distribution table
         for every turn, add on the hits
         overwrite the current distribution table with the new one
         
         */
        let distributionRef = analyticsRef.childByAppendingPath("lifetime distribution")
        getDataFromReference(distributionRef) {
            data in
            
            // Create new distribution table by adding together the current game's and what was stored
            let currentDistribution = data as! [String:[String:Int]]
            let gameDistribution = saveData.dataDict["analytics"] as! [String:[String:Int]]
            var newDistribution:[String:[String:Int]] = [:]
            for (area, hits) in currentDistribution {
                var newHitSection:[String:Int] = [:]
                for (hitSection, numTimes) in hits {
                    newHitSection[hitSection] = numTimes + gameDistribution[area]![hitSection]!
                }
                newDistribution[area] = newHitSection
            }
            
            // Upload and update by overwriting
            distributionRef.setValue(newDistribution)
        }
    }
}