//
//  CountdownPlayer.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 31/03/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

class CountdownPlayer: Player {
    
    override func endTurn() {
        super.endTurn()
    }
    
    init(startScore:UInt, cardID:String) {
        super.init(_cardID: cardID)
        self.score = Int(startScore)
    }
}
