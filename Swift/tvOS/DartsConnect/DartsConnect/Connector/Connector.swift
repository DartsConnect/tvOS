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
    optional func dartDidHit(hitValue:UInt, multiplier:UInt)
    optional func cardScanned(cardID:String)
    optional func dartboardDidConnect()
    optional func dartboardDisconnected(error:NSError?)
    optional func dartboardKickedMeOff(reason:String)
}

public extension String {
    /**
     Converts a String to NSData
     
     - returns: Data value of a String, in the data format UTF-8
     */
    func toData() -> NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding as NSStringEncoding, allowLossyConversion: false)!
    }
}

class Connector: NSObject, GCDAsyncSocketDelegate {
    
    // MARK: Variables
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
    let validHitSections:[UInt] = Array(1...20) + [25]
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
    enum ConversionError:ErrorType {
        case Failed
    }
    
    // MARK: Message Parsing
    /**
     Parses the message received by using the delimiter
     
     - parameter message: The string value of the message received
     
     - returns: A dictionary, where the keys are the target tags and values are the values
     */
    func parseMessage(message:String) -> [String:String]? {
        let parsedMessage = message.componentsSeparatedByString(messagePartsDelimiter)
        if parsedMessage.count > 1 {
            let tag = parsedMessage[0]
            let value = parsedMessage[1]
            return [ParsedMessageKey.Tag.rawValue:tag, ParsedMessageKey.Value.rawValue:value]
        }
        return nil
    }
    
    /**
     Converts a String to UInt
     
     - parameter str: The
     
     - throws: A type conversion error, of Failed
     
     - returns: An unwrapped uint value from the string.
     */
    func convertStringToUInt(str:String) throws -> UInt {
        guard let _ = UInt(str) else {
            throw ConversionError.Failed
        }
        return UInt(str)!
    }
    
    /**
     Deal with the parsed message
     
     - parameter parsedMessage: The parsed message from the string that was received.
     */
    func handleParsedMessage(parsedMessage:[String:String]) {
        let tag = parsedMessage["Tag"]!
        let value = parsedMessage["Value"]!
        
        switch tag {
        case "DartHit":
            let splitValues = value.componentsSeparatedByString(",") // Received data in the format hitSection,mutilplier
            if splitValues.count == 2 { // Just to make sure that I didn't get a corrupt message
                do {
                    let hitArea = try self.convertStringToUInt(splitValues[0])
                    if !validHitSections.contains(hitArea) { break } // If the hit area is not a valid section, exit this function and don't do anything
                    let multiplier = try self.convertStringToUInt(splitValues[1])
                    self.delegate?.dartDidHit?(hitArea, multiplier: multiplier)
                    if delegate == nil {
                        print("No Delegate for Dart Hit")
                    }
                } catch _ {
                    print("Failed to parse: \(parsedMessage)")
                }
            }
            break
        case "Card":
            print("Received Card: \(value)")
            self.delegate?.cardScanned?(value)
            break
        default:
            break
        }
    }
    
    /**
     Depending on the intonation of the "good bye", figure out whether or not to let the user he was kicked off, or properly disconnected
     
     - parameter parsedMessage: The parsed message from the string read from the data stream
     */
    func handleDisconnectMessage(parsedMessage:[String:String]) {
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
    }
    
    // MARK: Begin CocoaAsyncSocket Delegate Functions
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        self.sendString("CONNECT", dataTarget: .Connect, dataType: .String)
        dataSocket.readDataWithTimeout(-1, tag: 1) // Wait to receive a message with no time out
    }
    
    func socketDidCloseReadStream(sock: GCDAsyncSocket!) {
        delegate?.dartboardDisconnected?(nil)
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        if sock == dataSocket {
            /*
             *  Read the data received as a string and append it to a buffer
             *  Once the endFlag is found, parse the message
             */
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
                
                // For every part in all the parts of the message that is not empty ("")
                for part in parts {
                    if part != "" {
                        if let parsedMessage:[String:String] = self.parseMessage(part) {
                            // Handle connect message
                            if parsedMessage[ParsedMessageKey.Tag.rawValue] == DataTarget.Connect.rawValue {
                                if parsedMessage[ParsedMessageKey.Value.rawValue] == "Welcome" {
                                    delegate?.dartboardDidConnect?()
                                }
                            } else
                                // Handle disconnect message
                                if parsedMessage[ParsedMessageKey.Tag.rawValue] == DataTarget.Disconnect.rawValue {
                                    handleDisconnectMessage(parsedMessage)
                                } else {
                                    // For all other data, call the handleParsedMessage function
                                    if isDebugging { print(parsedMessage) }
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
                delegate?.dartboardDisconnected?(err)
            } else {
                if gotKicked {
                    delegate?.dartboardKickedMeOff?(kickReason)
                } else {
                    delegate?.dartboardDisconnected?(nil)
                }
                gotKicked = false
            }
        }
        self.disconnect()
        
        GlobalVariables.sharedVariables.connector = nil
        GlobalVariables.sharedVariables.bonjourManager = nil
    }
    // End Delegate Functions
    
    // MARK: Connection Controls
    /**
     If the data socket is connected, initiate the disconnect sequence
     */
    func disconnect() {
        if dataSocket.isConnected {
            self.sendString(deviceName, dataTarget: .Disconnect, dataType: .String)
        }
    }
    
    /**
     Start the connection process
     
     - returns: True or false depending on whether or not the connection succeeded
     */
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
    
    // MARK: Message Transmition
    /**
     Sends a string across the data socket
     
     - parameter value:      The value of the data to be sent
     - parameter dataTarget: The target destination of the data in the server's code
     - parameter dataType:   The data type of the data being sent
     */
    func sendString(value:String, dataTarget:DataTarget, dataType:DataType) {
        if dataSocket.isConnected {
            let message:String = dataTarget.rawValue + messagePartsDelimiter + dataType.rawValue + messagePartsDelimiter + value + endFlag
            dataSocket.writeData(message.toData(), withTimeout: 1, tag: 1)
        }
    }
    
    /**
     Sends an error to the server, if required
     
     - parameter message: The error message to send to the server
     */
    func sendError(message:String) {
        if dataSocket.isConnected {
            self.sendString(message, dataTarget: .Error, dataType: .String)
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
