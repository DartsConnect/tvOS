//
//  Connector.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 31/03/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

@objc protocol ConnectorDelegate {
    func dartDidHit(hitValue:UInt, multiplier:UInt)
    func dartboardDidConnect()
    func dartboardDisconnected(error:NSError?)
    func dartboardKickedMeOff(reason:String)
}

public extension String {
    func toData() -> NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding as NSStringEncoding, allowLossyConversion: false)!
    }
}

class Connector: NSObject, GCDAsyncSocketDelegate {
    var dataSocket:GCDAsyncSocket!
    var error:NSError?
    var ipAddress:String!
    var port:UInt16!
    var delegate:ConnectorDelegate?
    var keepListening:Bool = true
    var deviceName:String!
    var dataBuffer:String?
    var gotKicked:Bool = false
    var kickReason:String = ""
    let endFlag = "\\e"
    let messagePartsDelimiter = "|"
    enum ParsedMessageKey: String {
        case Tag = "Tag"
        case Value = "Value"
    }
    enum DataType:String {
        case String = "s"
        case Int = "i"
        case Double = "f"
        case Bool = "b"
    }
    enum DataTarget:String {
        case ScanLED = "scan led"
        case ThrowLED = "throw led"
        case Screen = "screen"
        
        case Connect = "CONNECT"
        case Disconnect = "DISCONNECT"
        case Error = "error"
    }
    
    func parseMessage(message:String) -> [String:String]? {
        let parsedMessage = message.componentsSeparatedByString(messagePartsDelimiter)
        if parsedMessage.count > 1 {
            let tag = parsedMessage[0]
            let value = parsedMessage[1]
            return [ParsedMessageKey.Tag.rawValue:tag, ParsedMessageKey.Value.rawValue:value]
        }
        return nil
    }
    
    func handleParsedMessage(parsedMessage:[String:String]) {
        let tag = parsedMessage["Tag"]!
        let value = parsedMessage["Value"]!
        
        switch tag {
        case "DartHit":
            let splitValues = value.componentsSeparatedByString(",")
            if splitValues.count == 2 {
                let hitArea = UInt(splitValues[0])!
                let multiplier = UInt(splitValues[1])!
                delegate?.dartDidHit(hitArea, multiplier: multiplier)
            }
            break
        case "ScannedCard":
            break
        default:
            break
        }
    }
    
    // Begin Delegate Functions
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        self.sendString("CONNECT", dataTarget: .Connect, dataType: .String)
        dataSocket.readDataWithTimeout(-1, tag: 1)
    }
    
    func socketDidCloseReadStream(sock: GCDAsyncSocket!) {
        delegate?.dartboardDisconnected(nil)
        //SVProgressHUD.showErrorWithStatus("Socket Closed Read Stream")
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        if sock == dataSocket {
            var messageSoFar = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            if dataBuffer == nil {
                dataBuffer = messageSoFar
            } else {
                messageSoFar = dataBuffer! + messageSoFar
            }
            
            if messageSoFar.rangeOfString(endFlag) == nil {
                dataBuffer = messageSoFar
            } else {
                dataBuffer = nil
                
                let parts = messageSoFar.componentsSeparatedByString(endFlag)
                
                for part in parts {
                    if part != "" {
                        if let parsedMessage:[String:String] = self.parseMessage(part) {
                            if parsedMessage[ParsedMessageKey.Tag.rawValue] == DataTarget.Connect.rawValue {
                                if parsedMessage[ParsedMessageKey.Value.rawValue] == "Welcome" {
                                    delegate?.dartboardDidConnect()
                                }
                            } else if parsedMessage[ParsedMessageKey.Tag.rawValue] == DataTarget.Disconnect.rawValue {
                                let message:String = parsedMessage[ParsedMessageKey.Value.rawValue]!
                                if message == "Bye" {
                                    keepListening = false
                                    gotKicked = false
                                    dataSocket.disconnect()
                                } else if message.rangeOfString("Leave") != nil {
                                    keepListening = false
                                    gotKicked = true
                                    kickReason = message.componentsSeparatedByString(":")[1]
                                    dataSocket.disconnect()
                                }
                            } else {
                                handleParsedMessage(parsedMessage)
                            }
                        }
                    }
                }
            }
        }
        dataSocket.readDataWithTimeout(-1, tag: 1)
    }
    
    func socket(sock: GCDAsyncSocket!, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        print("Partial")
    }
    
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        
    }
    
    func socket(sock: GCDAsyncSocket!, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        if sock == dataSocket {
            if keepListening {
                delegate?.dartboardDisconnected(err)
            } else {
                if gotKicked {
                    delegate?.dartboardKickedMeOff(kickReason)
                } else {
                    delegate?.dartboardDisconnected(nil)
                }
                gotKicked = false
            }
        }
        self.disconnect()
        
        GlobalVariables.sharedVariables.connector = nil
        GlobalVariables.sharedVariables.bonjourManager = nil
    }
    // End Delegate Functions
    
    func disconnect() {
        if dataSocket.isConnected {
            self.sendString(deviceName, dataTarget: .Disconnect, dataType: .String)
        }
    }
    
    func connect() -> Bool {
        keepListening = true
        
        let success:Bool = {
            do {
                try dataSocket.connectToHost(ipAddress, onPort: port, withTimeout: 5)
                return true
            } catch {
                print("Connect failed for some reason")
                return false
            }
        }()
        
        if !success {
            self.disconnect()
        }
        
        return success
    }
    
    func sendString(value:String, dataTarget:DataTarget, dataType:DataType) {
        if dataSocket.isConnected {
            let message:String = dataTarget.rawValue + messagePartsDelimiter + dataType.rawValue + messagePartsDelimiter + value + endFlag
            dataSocket.writeData(message.toData(), withTimeout: 1, tag: 1)
        }
    }
    
    func sendError(message:String) {
        if dataSocket.isConnected {
            self.sendString(message, dataTarget: .Error, dataType: .String)
            //self.sendString(message, tag: "ERROR", tileType: TileType.Console)
        }
    }
    
    init(IPAddress:String, _port:UInt16/*, _imagePort:Int*/) {
        super.init()
        dataSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        dataSocket.delegate = self
        
        ipAddress = IPAddress
        port = _port
    }
}
