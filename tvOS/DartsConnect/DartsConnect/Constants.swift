//
//  Constants.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 4/04/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

let isDebugging:Bool = true

enum GameType:String {
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