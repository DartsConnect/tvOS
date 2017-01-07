//
//  BonjourManager.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 18/04/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation
import UIKit

protocol BonjourManagerDelegate {
    func bmFoundServices(serviceNames:[String])
}

class BonjourManager: NSObject, NSNetServiceBrowserDelegate, NSNetServiceDelegate {
    let netServiceBrowser:NSNetServiceBrowser = NSNetServiceBrowser()
    let serviceType:String = "_dartsconnect._tcp"
    var serverService:NSNetService?
    var servicesFound:[NSNetService] = []
    var delegate:BonjourManagerDelegate?
    
    // MARK: NSNetService Delegate Methods
    
    func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {
        print("Begin Searching")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("DidNotSearch: \(errorDict)")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        print("DidFindService: \(service.name)")
        servicesFound.append(service)
        if moreComing {
            
        } else {
            if servicesFound.count == 1 {
                serverService = servicesFound.first
            } else {
                // TODO: Implement what to do if there are many dartboards in the house.
                print("Multiple Services Found... Don't know what to do yet.")
            }
            if serverService != nil {
                serverService?.delegate = self
                serverService?.resolveWithTimeout(5)
            }
        }
    }
    
    func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
        print("DidStopSearch")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        print("DidRemoveService")
    }
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        let address = sender.addresses![0]
        
        /*
         *  This code was pulled from StackOverflow
         *  It takes the ip data from the NSNetService and unwraps it to reveal the ip as a string
         */
        let ptr = UnsafePointer<sockaddr_in>(address.bytes)
        var addr = ptr.memory.sin_addr
        let buf = UnsafeMutablePointer<Int8>.alloc(Int(INET6_ADDRSTRLEN))
        let family = ptr.memory.sin_family
        var ipc = UnsafePointer<Int8>()
        if family == __uint8_t(AF_INET) {
            ipc = inet_ntop(Int32(family), &addr, buf, __uint32_t(INET6_ADDRSTRLEN))
        }
        if let ip = String.fromCString(ipc) {
            print("DidResolve: \(ip):\(sender.port)")
            
            if GlobalVariables.sharedVariables.connector == nil {
                GlobalVariables.sharedVariables.connector = Connector(IPAddress: ip, _port: UInt16(sender.port))
                GlobalVariables.sharedVariables.connector?.connect()
            }
        } else {
            print("Failed to resolve")
        }
    }
    
    // MARK: End NSNetService Delegate Methods
    
    /**
     Start scanning for bonjour services
     */
    func startScanning() {
        netServiceBrowser.delegate = self
        netServiceBrowser.searchForServicesOfType(serviceType, inDomain: "local")
        print("Begin Scanning for Bonjour Services")
    }
    
    init(_ del:BonjourManagerDelegate?) {
        super.init()
        delegate = del
        startScanning()
    }
}
