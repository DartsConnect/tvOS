//
//  DBSaveGameData.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 7/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation
import Firebase

// MARK: Saving Game Data
extension DatabaseManager {
    /**
     Turns the NSDate into Unix Epoch time in a string
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameter timestamp: The NSDate to convert
     - returns: A save ready string containing the timestamp from the NSDate
     - todo: None
     */
    func formattedDateString(timestamp:NSDate) -> String {
        return "\(Int(timestamp.timeIntervalSince1970 * timestampFactor))"
    }
    
    /**
     This function gets called when saving game data
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameter saveData: The game data to save
     - returns: None
     - todo: None
     */
    func saveGameData(saveData:GameSaveData) {
        let playDataRef = rootRef.childByAppendingPath("playData/\(saveData.user.uid!)")
        
        print("Begin updating lookup dict")
        updateGamesLookupDict(playDataRef, gameType: saveData.gameType, timestamp: saveData.timestamp)
        print("Begin writing game data")
        writeGameData(playDataRef, timestamp: saveData.timestamp, dataDict: saveData.dataDict)
        print("Update achievements lookup")
        updateAchievementsLookup(playDataRef, saveData: saveData)
        print("Update all time analysis")
        updateAllTimeAnalytics(playDataRef, saveData: saveData)
        print("Done Save")
    }
    
    /**
     Adds the game being saved to the look up dictionary
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameter playDataRef: The playData ref for the user who's game data is being saved
     - parameter gameType:    The type of game that was being played
     - parameter timestamp:   The NSDate for the timestamp
     - returns: None
     - todo: None
     */
    private func updateGamesLookupDict(playDataRef:Firebase, gameType:GameType, timestamp:NSDate) {
        let gamesLookupRef = playDataRef.childByAppendingPath("gamesLookup").childByAppendingPath(formattedDateString(timestamp))
        gamesLookupRef.updateChildValues(
            [
                "gameType":gameType.title!,
                "timestamp":formattedDateString(timestamp)
            ]
        )
    }
    
    /**
     Saved the game into the user's dictionary
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameter playDataRef: The playData ref for the user who's game data is being saved
     - parameter timestamp:   The NSDate for the timestamp
     - parameter dataDict:    The save data dict from saveData
     - returns: None
     - todo: None
     */
    private func writeGameData(playDataRef:Firebase, timestamp:NSDate, dataDict:[String:AnyObject]) {
        let gamesRef = playDataRef.childByAppendingPath("games/\(formattedDateString(timestamp))")
        gamesRef.setValue(dataDict)
    }
    
    /**
     Updates the achievements lookup dictionary
     
     - author: Jordan Lewis
     - date: Saturday 28 May 2016
     - parameter playDataRef: The playData ref for the user who's game data is being saved
     - parameter saveData:    The game data to save
     - returns: None
     - todo: None
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
     Updates the lifetime analytics with this game data
     
     Look for:
     playData -> uid -> analytics
     
     - author: Jordan Lewis
     - date: Saturday 28 May 2016, Wednesday 06 July 2016
     - parameter playDataRef: The playData ref for the user who's game data is being saved
     - parameter saveData:    The game data to save
     - returns: None
     - todo: None
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
                    if data is NSNull { // If cut-throat data has never been saved before, just store what we have now
                        cutThroatStats.setValue([
                            "onMe":tMe,
                            "onOthers":tOthers
                            ])
                    } else { // If it has been saved before, add on today's stats
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
                    if data is NSNull {
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
            
            let gameDistribution = DistributionFixer().fixKeysToRead(saveData.dataDict["analytics"]!["distribution"] as! DistributionDict)
            
            if data is NSNull {
                distributionRef.setValue(DistributionFixer().fixKeysToSave(gameDistribution))
            } else {
                // Create new distribution table by adding together the current game's and what was stored
                let currentDistribution = DistributionFixer().fixKeysToRead(data as! DistributionDict)
                var newDistribution:DistributionDict = [:]
                for (area, hits) in currentDistribution {
                    var newHitSection:[String:Int] = [:]
                    for (hitSection, numTimes) in hits {
                        newHitSection[hitSection] = numTimes + gameDistribution[area]![hitSection]!
                    }
                    newDistribution[area] = newHitSection
                }
                // Upload and update by overwriting
                distributionRef.setValue(DistributionFixer().fixKeysToSave(newDistribution))
                
            }
            
        }
    }
}