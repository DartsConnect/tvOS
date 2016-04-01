//
//  Connector.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 31/03/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

@objc protocol DartBoardInput {
    func dartDidHit(hitValue:UInt, multiplier:UInt)
}

class Connector: NSObject {
    
}
