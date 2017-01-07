//
//  GlobalVars.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 29/04/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

private let _sharedGlobalVariables = GlobalVariables()

/**
 *  This is a Singleton file/class, if you're not sure what it is,
 *  its just a class that only ever has one instance in the program
 */
class GlobalVariables:NSObject {
    
    var connector:Connector?
    var bonjourManager:BonjourManager?
    
    var menuvc:ViewController?
    
    var currentGame:Game?
    
    var dbManager:DatabaseManager = DatabaseManager(authenticateAnonymously:true)
    
    class var sharedVariables: GlobalVariables {
        return _sharedGlobalVariables
    }
}