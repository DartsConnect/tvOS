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
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    mutating func setOpponents(opponenets:[User]) {
        let registeredPlayers = opponenets.map {$0.uid}.filter {$0 != nil && $0 != user.uid} as! [String]
        let guests = opponenets.filter {$0.uid == nil}.map {$0.username} as! [String]
        dataDict["opponents"] = (registeredPlayers + guests).toDict
    }
    
    /**
     
     - author: Jordan Lewis
     - date: Wednesday 25 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    mutating func setTurns(turns:DartGame) {
        dataDict["achievements"] = turns.allAchievements.mapValues {$1.fullName}
        dataDict["analytics"] = DartGameDistribution(gameThrows: turns).saveDataDict
        dataDict["turns"] = turns.saveDataDict
    }
    
    /**
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameters:
     - None
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
     <#Description#>
     
     - author: Jordan Lewis
     - date: Wednesday 06 July 2016
     - todo: DOCUMENT THIS
     - parameter isCutThroat: <#isCutThroat description#>
     - parameter thisPlayer:  <#thisPlayer description#>
     - parameter allPlayers:  <#allPlayers description#>
     */
    mutating func setCricketScores(isCutThroat:Bool, thisPlayer:CricketPlayer, allPlayers:[CricketPlayer]) {
        if isCutThroat {
            var onOthers:[String:Int] = [:]
            for (player, score) in thisPlayer.amountCut {
                if let uid = player.user.uid {
                    onOthers[uid] = Int(score)
                } else {
                    onOthers[player.user.username] = Int(score)
                }
            }
            
            var onMe:[String:Int] = [:]
            for (player, score) in thisPlayer.gotCutBy {
                if let uid = player.user.uid {
                    onMe[uid] = Int(score)
                } else {
                    onMe[player.user.username] = Int(score)
                }
            }
            
            dataDict["cut-throat scores"] = [
                "onMe":onMe,
                "onOthers":onOthers
            ]
        }
        dataDict["score"] = thisPlayer.score
    }
    
    /**
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    func pushToDatabase() {
        GlobalVariables.sharedVariables.dbManager.saveGameData(self)
    }
    
    init(player:Player, aGameType:GameType, thisGame:Game, aTimestamp:NSDate) {
        user = player.user
        gameType = aGameType
        timestamp = aTimestamp
        
        setOpponents(thisGame.players.map {$0.user})
        setTurns(player.gameScores)
        
        switch gameType.gameClass {
        case .CountDown:
            let cGame = thisGame as! CountdownGame
            setCountdownConditions(cGame.openCriteria, closeC: cGame.closeCriteria)
            dataDict["score"] = player.score
            break
        case .Cricket:
            let cGame = thisGame as! CricketGame
            setCricketScores(cGame.isCutThroat, thisPlayer: player as! CricketPlayer, allPlayers: cGame.players as! [CricketPlayer])
            break
        default:
            break
        }
    }
}