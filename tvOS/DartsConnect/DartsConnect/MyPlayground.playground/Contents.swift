//: Playground - noun: a place where people can play

import Cocoa
import Foundation
/*
class bonjour:NSObject, NSNetServiceBrowserDelegate {
    func start() {
        let serviceBrowser = NSNetServiceBrowser()
        serviceBrowser.delegate = self
        serviceBrowser.searchForServicesOfType("_dartsconnect._tcp", inDomain: "local")
    }
    
    func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
        print("Stop")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("Did not search")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        print("Found domain")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        print("Remove Service")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        print("Remove Domain")
    }
    
    func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {
        print("Will Search")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        print("Found \(service.name)")
    }
}

bonjour().start()
*/


func stripOrderNumbers(bc:[String]) -> [String] {
    var nbc:[String] = []
    for c in bc {
        nbc.append(c.componentsSeparatedByString(":")[1])
    }
    return nbc
}

let a = ["0:1","0:1","0:1","0:1"]
print(stripOrderNumbers(a))
print(a.map {$0.componentsSeparatedByString(":")[1]})

let ps = ["nil", "2", "nil", "3"]
print(ps.filter {$0 != "nil"})

let ts = [(1,2), (3,3)]
let tss = ts.map {$0.0 * $0.1}.reduce(0, combine: +)
print(tss)