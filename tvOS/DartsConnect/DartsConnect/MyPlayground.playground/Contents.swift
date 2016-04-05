//: Playground - noun: a place where people can play

import Cocoa

let gamesOptions:[String:[String:[String]]] = [
    "0:01":[
        "Type":["301", "501", "701", "901", "1001"],
        "Open":["Any", "Single", "Double", "Triple", "Bull", "Double Bull"],
        "Close":["Any", "Single", "Double", "Triple", "Bull", "Double Bull"],
        "Add Players":["1+"]
    ],
    "1:Cricket":[
        "Type":["Cricket", "Cut-Throat"],
        "Add Players":["2+"]
    ],
    "2:Free":[
        "Type":["Cricket", "Cut-Throat"],
        "Add Players":["2+"]
    ],
    "3:20 to 1":[
        "Type":["Cricket", "Cut-Throat"],
        "Add Players":["2+"]
    ],
    "4:World":[
        "Type":["Cricket", "Cut-Throat"],
        "Add Players":["2+"]
    ],
    "5:More":[
        "Type":["Cricket", "Cut-Throat"],
        "Add Players":["2+"]
    ]
    
]

var keys = [String](gamesOptions.keys)
var a = keys.sort()

print(keys.sortInPlace())

let c = "2+"
let d = [Character](c.characters)