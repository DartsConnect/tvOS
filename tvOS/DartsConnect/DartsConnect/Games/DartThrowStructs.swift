//
//  DartThrowStructs.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 27/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

// Saturday 28 May 2016
indirect enum Achievement {
    case Ton80, HighTon, LowTon, HatTrick, ThreeInTheBlack, ThreeInABed, HatTrickLT, HatTrickHT
    
    var shortName:String {
        get {
            switch self {
            case .Ton80:
                return "t80"
            case .HighTon:
                return "hTon"
            case .LowTon:
                return "lTon"
            case .HatTrick:
                return "HT"
            case .HatTrickLT:
                return "HT&lTon"
            case .HatTrickHT:
                return "HT&hTon"
            case .ThreeInTheBlack:
                return "3itB"
            case .ThreeInABed:
                return "3iaB"
            }
        }
    }
    
    var fullName:String {
        get {
            switch self {
            case .Ton80:
                return "Ton 80"
            case .HighTon:
                return "High Ton"
            case .LowTon:
                return "Low Ton"
            case .HatTrick:
                return "Hat Trick"
            case .HatTrickLT:
                return "Hat Trick & Low Ton"
            case .HatTrickHT:
                return "Hat Trick & High Ton"
            case .ThreeInTheBlack:
                return "Three in the Black"
            case .ThreeInABed:
                return "Three in a Bed"
            }
        }
    }
    
    init?(shortName:String) {
        switch shortName {
        case "t80": self = .Ton80
        case "hTon": self = .HighTon
        case "lTon": self = .LowTon
        case "HT": self = .HatTrick
        case "HT&lTon": self = .HatTrickLT
        case "HT&hTon": self = .HatTrickHT
        case "3itB": self = .ThreeInTheBlack
        case "3iaB": self = .ThreeInABed
        default:
            return nil
        }
    }
    
    init?(longName:String) {
        switch longName {
        case "Ton 80": self = .Ton80
        case "High Ton": self = .HighTon
        case "Low Ton": self = .LowTon
        case "Hat Trick": self = .HatTrick
        case "Hat Trick & Low Ton": self = .HatTrickLT
        case "Hat Trick & High Ton": self = .HatTrickHT
        case "Three in the Black": self = .ThreeInTheBlack
        case "Three in a Bed": self = .ThreeInABed
        default:
            return nil
        }
    }
}

protocol Saveable { // Friday 27 May 2016
    var saveDataDict:[String:AnyObject] { get }
}

// MARK: Dart Game Throw Distribution
struct DartGameDistribution:Saveable {
    var game:DartGame!
    var distributionDict:[String:[String:Int]] = [:]
    var mostCommonHit:[DartHit] = []
    var leastCommonHit:[DartHit] = []
    var mostCommonSection:[Int] = []
    var leastCommonSection:[Int] = []
    
    var saveDataDict: [String : AnyObject] {
        get {
            return [
                "distribution":distributionDict,
                "mch":mostCommonHit.map {$0.saveDataDict}.toDict,
                "lch":leastCommonHit.map {$0.saveDataDict}.toDict,
                "mcs":mostCommonSection.toDict,
                "lcs":leastCommonSection.toDict
            ]
        }
    }
    
    /**
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    private mutating func generateDistributionDict() {
        var gameDistribution:[String:[String:Int]] = [:]
        
        // Fill the life time distribution updater dict with zeros
        for hit in 1...21 {
            let adjHit = hit == 21 ? 25 : hit
            if adjHit == 25 {
                gameDistribution[adjHit.toString] = [
                    "1":0,
                    "2":0
                ]
            } else {
                gameDistribution[adjHit.toString] = [
                    "1":0,
                    "2":0,
                    "3":0,
                ]
            }
        }
        
        for num in 1...21 {
            let adjNum = num == 21 ? 25 : num
            for hit in game.allThrows where hit.section == UInt(adjNum) {
                gameDistribution[adjNum.toString]![hit.multiplier.toString]! += 1
            }
        }
        distributionDict = gameDistribution
    }
    
    /**
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    private mutating func findMostCommonHit() {
        var highest:(DartHit, Int) = (DartHit(hitSection: 1, hitMultiplier: 1), 0)
        var othersAtSame:[DartHit] = []
        for (section, sectionDict) in distributionDict {
            var highestMultiplier:(String, Int) = ("1", 0)
            for (multi, hitCount) in sectionDict {
                if hitCount > highestMultiplier.1 {
                    highestMultiplier = (multi, hitCount)
                }
            }
            if highestMultiplier.1 > highest.1 {
                othersAtSame.removeAll()
                highest = (DartHit(hitSection: UInt(section)!, hitMultiplier: UInt(highestMultiplier.0)!), highestMultiplier.1)
            } else if highestMultiplier.1 == highest.1 {
                othersAtSame.append(DartHit(hitSection: UInt(section)!, hitMultiplier: UInt(highestMultiplier.0)!))
            }
        }
        othersAtSame.append(highest.0)
        mostCommonHit = othersAtSame
    }
    
    /**
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    private mutating func findLeastCommonHit() {
        let mostCommon = mostCommonHit.first!
        var lowest:(DartHit, Int) = (mostCommon, distributionDict[mostCommon.section.toString]![mostCommon.multiplier.toString]!)
        var othersAtSame:[DartHit] = []
        for (section, sectionDict) in distributionDict {
            var lowestMultiplier:(String, Int) = ("1", 0)
            for (multi, hitCount) in sectionDict {
                if hitCount < lowestMultiplier.1 {
                    lowestMultiplier = (multi, hitCount)
                }
            }
            if lowestMultiplier.1 < lowest.1 {
                othersAtSame.removeAll()
                lowest = (DartHit(hitSection: UInt(section)!, hitMultiplier: UInt(lowestMultiplier.0)!), lowestMultiplier.1)
            } else if lowestMultiplier.1 == lowest.1 {
                othersAtSame.append(DartHit(hitSection: UInt(section)!, hitMultiplier: UInt(lowestMultiplier.0)!))
            }
        }
        othersAtSame.append(lowest.0)
        leastCommonHit = othersAtSame
    }
    
    /**
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    private mutating func findMostCommonSection() {
        var othersAtSame:[Int] = []
        var highest:(Int, Int) = (0, 0)
        for (section, sectionDict) in distributionDict {
            let currentCount = sectionDict.map {$0.1}.reduce(0, combine: +)
            if currentCount > highest.1 {
                othersAtSame.removeAll()
                highest = (section.toInt()!, currentCount)
            } else if currentCount == highest.1 {
                othersAtSame.append(section.toInt()!)
            }
        }
        othersAtSame.append(highest.0)
        mostCommonSection = othersAtSame
    }
    
    /**
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    private mutating func findLeastCommonSection() {
        var othersAtSame:[Int] = []
        var lowest:(Int, Int) = (0, 0)
        for (section, sectionDict) in distributionDict {
            let currentCount = sectionDict.map {$0.1}.reduce(0, combine: +)
            if currentCount < lowest.1 {
                othersAtSame.removeAll()
                lowest = (section.toInt()!, currentCount)
            } else if currentCount == lowest.1 {
                othersAtSame.append(section.toInt()!)
            }
        }
        othersAtSame.append(lowest.0)
        mostCommonSection = othersAtSame
    }
    
    init(gameThrows:DartGame) {
        
        game = gameThrows
        
        generateDistributionDict()
        findMostCommonHit()
        findLeastCommonHit()
        findMostCommonSection()
        findLeastCommonSection()
    }
}

// MARK: DartGame
struct DartGame:Saveable { // Friday 27 May 2016
    var allTurns:[DartTurn] = []
    
    var allThrows:[DartHit] {
        get {
            return allTurns.map {$0.protectedThrows}.reduce([], combine: +)
        }
    }
    
    var saveDataDict:[String:AnyObject] {
        get {
            return allTurns.map {
                $0.saveDataDict
                }.toDict
        }
    }
    
    var allAchievements:[String:Achievement] {
        get {
            var allAch:[String:Achievement] = [:]
            for i in 0..<allTurns.count {
                if let ach = allTurns[i].achievement {
                    allAch[i.toString] = ach
                }
            }
            return allAch
        }
    }
    
    var numTurns:Int {
        get {
            return allTurns.count
        }
    }
    
    mutating func addTurn(turn:DartTurn) {
        if turn.numThrows > 0 {
            allTurns.append(turn)
        }
    }
}

// MARK: DartTurn
struct DartTurn:Saveable { // Friday 27 May 2016
    private var allThrows:[DartHit] = []
    
    var protectedThrows:[DartHit] {
        get {
            return allThrows
        }
    }
    
    var numThrows:Int {
        get {
            return allThrows.count
        }
    }
    
    var turnTotal:UInt {
        get {
            return allThrows.map {$0.section * $0.multiplier}.reduce(0, combine: +)
        }
    }
    
    var didBust:Bool {
        get {
            return allThrows.filter {$0.didBust}.count > 0
        }
    }
    
    private var isLowTon:Bool {
        get {
            return turnTotal > 100 && turnTotal <= 150
        }
    }
    
    private var isHighTon:Bool {
        get {
            return turnTotal > 150
        }
    }
    
    private var isTon80:Bool {
        get {
            return turnTotal == 180
        }
    }
    
    func isAllInSection(section:UInt) -> Bool {
        return allThrows.filter {$0.section == section}.count == allThrows.count
    }
    
    func isAllInMultiplier(multiplier:UInt) -> Bool {
        return allThrows.filter {$0.multiplier == multiplier}.count == allThrows.count
    }
    
    private var isThreeInABed:Bool {
        get {
            return isAllInMultiplier(allThrows.first!.multiplier) && isAllInSection(allThrows.first!.section)
        }
    }
    
    private var isHatTrick:Bool {
        get {
            return isAllInSection(25)
        }
    }
    
    private var isThreeInTheBlack:Bool {
        get {
            return isHatTrick && isAllInMultiplier(2)
        }
    }
    
    /* Need to know if the game is cricket.
     private var isWhiteHorse:Bool {
     get {
     return isAllInMultiplier(3)
     }
     }
     */
    
    var achievement:Achievement? {
        get {
            if isTon80 {
                return .Ton80
            }
            if isThreeInTheBlack {
                return .ThreeInTheBlack
            }
            if isHatTrick {
                return isHighTon ? .HatTrickHT : (isLowTon ? .HatTrickLT : .HatTrick)
            }
            if isThreeInABed {
                return .ThreeInABed
            }
            if isHighTon {
                return .HighTon
            }
            if isLowTon {
                return .LowTon
            }
            return nil
        }
    }
    
    var saveDataDict:[String:AnyObject] {
        get {
            return allThrows.map {
                $0.saveDataDict
                }.toDict
        }
    }
    
    mutating func addThrow(hit:DartHit) {
        if allThrows.count < 3 { allThrows.append(hit) }
    }
}

// MARK: Dart Hit
struct DartHit:Saveable { // Tuesday 24 May 2016
    let section:UInt!
    let multiplier:UInt!
    let totalHitValue:UInt!
    enum ZeroHitReason:String {
        case Bust = "Bust"
        case NotOpenCriteria = "Not Close Criteria"
        case Missed = "Missed"
    }
    var reason:ZeroHitReason? = nil
    var didBust:Bool {
        get {
            return reason == nil
        }
    }
    
    var saveDataDict:[String:AnyObject] {
        get {
            var toReturn:[String:AnyObject] = [
                "section":section,
                "multiplier":multiplier
            ]
            if !didBust {
                toReturn["reason"] = reason!.rawValue
            }
            return toReturn
        }
    }
    
    init(hitSection:UInt, hitMultiplier:UInt) {
        section = hitSection
        multiplier = hitMultiplier
        totalHitValue = section * multiplier
    }
}