//
//  GlobalVars.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 29/04/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

private let _sharedGlobalVariables = GlobalVariables()

class GlobalVariables:NSObject {
    
    var connector:Connector?
    var bonjourManager:BonjourManager?
    
    var currentGame:Game?
    
    class var sharedVariables: GlobalVariables {
        return _sharedGlobalVariables
    }
}