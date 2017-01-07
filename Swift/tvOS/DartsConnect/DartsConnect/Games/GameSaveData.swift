//
//  GameSaveData.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 24/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

// MARK: Save Data Struct
struct GameSaveData { // Tuesday 24 May 2016
    var user:User!
    var gameType:GameType!
    var timestamp:NSDate!
    var dataDict:[String:AnyObject] = [:]
    
    /**
     Set the opponents for the game
     Will seperate guests from registered players
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameter opponents: A list of users
     - returns: None
     - todo: None
     */
    mutating func setOpponents(opponents:[User]) {
        let registeredPlayers = opponents.map {$0.uid}.filter {$0 != nil && $0 != user.uid}.map {$0!} as [String]
        let guests:[String] = opponents.filter {$0.uid == nil}.map {$0.username}
        dataDict["opponents"] = (registeredPlayers + guests).toDict
    }
    
    /**
     Set the all the turns for the game
     Also do achievements, and analytics together, from extrapolating turn data
     
     - author: Jordan Lewis
     - date: Wednesday 25 May 2016
     - parameters turns: A DartGame containing all the turns
     - returns: None
     - todo: None
     */
    mutating func setTurns(turns:DartGame) {
        dataDict["achievements"] = turns.allAchievements.mapValues {$1.fullName}
        dataDict["analytics"] = DartGameDistribution(gameThrows: turns).saveDataDict
        dataDict["turns"] = turns.saveDataDict
    }
    
    /**
     Set the countdown open and close conditions for the game
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameter openC:  A list of GameEndsCriteria
     - parameter closeC: A list of GameEndsCriteria
     - returns: None
     - todo: None
     */
    mutating func setCountdownConditions(openC:[GameEndsCriteria], closeC:[GameEndsCriteria]) {
        dataDict["conditions"] = [
            "open":openC.map {$0.rawValue}.toDict,
            "close":closeC.map {$0.rawValue}.toDict
        ]
    }
    
    /**
     Set the cricket scores for the game
     If the game is cut-throat, then
     Also store who cut this player, and who this player cut
     
     - author: Jordan Lewis
     - date: Wednesday 06 July 2016
     - todo: DOCUMENT THIS
     - parameter isCutThroat: Whether or not the game was cut-throat
     - parameter thisPlayer:  The player this user was assigned to
     - parameter allPlayers:  An array of all the players in the game
     */
    mutating func setCricketScores(isCutThroat:Bool, thisPlayer:CricketPlayer, allPlayers:[CricketPlayer]) {
        if isCutThroat {
            // Store who this player cut and by how much
            var onOthers:[String:Int] = [:]
            for (player, score) in thisPlayer.amountCut {
                if let uid = player.user.uid { // If the user is not a Guest
                    onOthers[uid] = Int(score) // Use their UID to reference that user.
                } else { // Otherwise, use the username "Guest x" to save the data
                    onOthers[player.user.username] = Int(score)
                }
            }
            
            // Store who cut this player and by how much
            var onMe:[String:Int] = [:]
            for (player, score) in thisPlayer.gotCutBy {
                if let uid = player.user.uid { // If the user is not a Guest
                    onMe[uid] = Int(score) // Use their UID to reference that user.
                } else { // Otherwise, use the username "Guest x" to save the data
                    onMe[player.user.username] = Int(score)
                }
            }
            
            // Store both into the data dictionary to be saved
            dataDict["cut-throat scores"] = [
                "onMe":onMe,
                "onOthers":onOthers
            ]
        }
        // Store the player's score regardless of cut-throat or not
        dataDict["score"] = thisPlayer.score
    }
    
    /**
     Push the game data to Firebase
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - returns: None
     - todo: None
     */
    func pushToDatabase() {
        GlobalVariables.sharedVariables.dbManager.saveGameData(self)
    }
    
    /**
     Initialises the GameSave Data Struct
     
     - parameter player:     The player who's game is going to be saved
     - parameter aGameType:  The type of game being saved
     - parameter thisGame:   The game class instance being saved
     - parameter aTimestamp: The timestamp from when this game started, to be used to refer to the game
     
     - returns: An initialised version of GameSaveData, ready to push to Firebase
     */
    init(player:Player, aGameType:GameType, thisGame:Game, aTimestamp:NSDate) {
        user = player.user
        gameType = aGameType
        timestamp = aTimestamp
        
        setOpponents(thisGame.players.map {$0.user})
        setTurns(player.gameScores)
        
        // Handle different save styles for different types of games.
        switch gameType.gameClass! {
        case .CountDown:
            let cGame = thisGame as! CountdownGame
            setCountdownConditions(cGame.openCriteria, closeC: cGame.closeCriteria)
            dataDict["score"] = player.totalNumberOfThrows
            break
        case .Cricket:
            let cGame = thisGame as! CricketGame
            setCricketScores(cGame.isCutThroat, thisPlayer: player as! CricketPlayer, allPlayers: cGame.players as! [CricketPlayer])
            break
        case .World:
            dataDict["score"] = player.totalNumberOfThrows
        default:
            break
        }
        
        /*
         *  For all games but world, the user's score is their in game score.
         *  World uses the number of turns as a score, that is handled above.
         */
        if gameType.gameClass! != .World && gameType.gameClass! != .CountDown {
            dataDict["score"] = player.score
        }
    }
}