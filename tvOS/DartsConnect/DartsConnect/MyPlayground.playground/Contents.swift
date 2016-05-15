//: Playground - noun: a place where people can play

import Cocoa
import Foundation

for playerCount in 2...4 {
    print("Player Count: \(playerCount)")
    for index in 0..<playerCount {
        let spacerAdj = playerCount <= 2 ? 1 : 0
        
        let ppviAdj = playerCount <= 2 ? (index == 0 ? 1 : -1) : (index == 0 ? playerCount - 1 : -1)
        let nindex = index + spacerAdj + ppviAdj
        print("Previous: \(nindex) Current: \(index)")
    }
}