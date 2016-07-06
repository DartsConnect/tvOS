//
//  Constants.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 4/04/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

let isDebugging:Bool = true

// Saturday 28 May 2016
enum GameType {
    case Free(rounds:Int)
    case Countdown(startValue:UInt)
    case Cricket(cutThroat:Bool)
    case World
    
    var gameClass:GameClass {
        switch self {
        case .Free:
            return .Free
        case .Countdown:
            return .CountDown
        case .Cricket:
            return .Cricket
        case .World:
            return .World
        }
    }
    
    var title:String {
        switch self {
        case .Free(let rounds):
            return "Free \(rounds)"
        case .Countdown(let startValue):
            return "Countdown \(startValue)"
        case .Cricket(let cutThroat):
            return "\(cutThroat ? "Cut-Throat ":"")Cricket"
        case .World:
            return "World"
        }
    }
}

enum GameClass:String {
    case CountDown = "01"
    case Cricket = "Cricket"
    case Free = "Free"
    case TwentyToOne = "20 to 1"
    case World = "World"
}

enum GameEndsCriteria:String {
    case Any = "Any"
    case OnSingle = "Single"
    case OnDouble = "Double"
    case OnTriple = "Triple"
    case OnBull = "Bull"
    case OnDoubleBull = "Double Bull"
}

enum ForceEndTurnReason:CustomStringConvertible {
    case Bust
    case OpenOn(criteria: GameEndsCriteria)
    case CloseOn(criteria: GameEndsCriteria)
    
    var description: String {
        switch self {
        case Bust:
            return "Bust"
        case let OpenOn(reason):
            return "Open on \(reason)"
        case let CloseOn(reason):
            return "Close on \(reason)"
        }
    }
}