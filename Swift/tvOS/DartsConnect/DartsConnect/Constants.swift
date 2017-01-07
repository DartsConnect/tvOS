//
//  Constants.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 4/04/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

let isDebugging:Bool = false

/**
 The Criteria for opening and finishing a game in countdown
 
 - Any:          Any hit will open or close the game
 - OnSingle:     The dart must land in a single hit area
 - OnDouble:     The dart must land in a double hit area
 - OnTriple:     The dart must land in a triple hit area
 - OnBull:       The dart must hit any Bulls Eye
 - OnDoubleBull: The dart must hit the Double Bulls Eye
 */
enum GameEndsCriteria:String {
    case Any = "Any"
    case OnSingle = "Single"
    case OnDouble = "Double"
    case OnTriple = "Triple"
    case OnBull = "Bull"
    case OnDoubleBull = "Double Bull"
}

/**
 An encapsulation of information/reasons on why a DartHit might have a 0
 
 - Bust:        The user did not finish and busted
 - OpenOn:      The user did not hit the required section to open
 - CloseOn:     The user did not hit the required section to close
 */
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