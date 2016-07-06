import Foundation

var distributionDict:[String:[String:Int]] = [
"1":[
    "1":1,
    "2":4,
    "3":20
    ],
"2":[
    "1":1,
    "2":4,
    "3":15
    ]
]
var temp:[String:Int] = [:]
for (section, sectionDict) in distributionDict {
    temp[section] = sectionDict.map {$0.1}.reduce(0, combine: +)
}
print(temp)

print(NSDate())