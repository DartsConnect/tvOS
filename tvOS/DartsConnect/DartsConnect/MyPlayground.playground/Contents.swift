//: Playground - noun: a place where people can play

import Cocoa
import Foundation
//import Firebase

for playerCount in 2...4 {
    print("Player Count: \(playerCount)")
    for index in 0..<playerCount {
        let spacerAdj = playerCount <= 2 ? 1 : 0
        
        let ppviAdj = playerCount <= 2 ? (index == 0 ? 1 : -1) : (index == 0 ? playerCount - 1 : -1)
        let nindex = index + spacerAdj + ppviAdj
        print("Previous: \(nindex) Current: \(index)")
    }
}

func generateRandomPassword() -> String {
    let lower = "abcdefghijklmnopqrstuvwxyz".characters.map {"\($0)"}
    let upper = lower.map { $0.uppercaseString }
    let numbers = "0123456789".characters.map {"\($0)"}
    let allChars = lower + upper + numbers
    let length = Int(arc4random_uniform(16) + 8)
    var pass = ""
    for _ in 0..<length {
        let char = allChars[Int(arc4random_uniform(UInt32(allChars.count)))]
        pass += char
    }
    return pass
}
for _ in 0...10 {
    print(generateRandomPassword())
}