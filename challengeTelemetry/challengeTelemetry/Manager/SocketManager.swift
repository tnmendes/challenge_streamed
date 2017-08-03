//
//  SocketManager.swift
//  challengeTelemetry
//
//  Created by Tiago Mendes on 02/08/2017.
//  Copyright © 2017 Tiago Mendes. All rights reserved.
//

import Foundation
import CocoaAsyncSocket



class SocketManager: NSObject, GCDAsyncUdpSocketDelegate {

    var sensorData: SensorData? = nil
    var port: UInt16 = 0
    var host: String = Configuration.defaultHost
    
    var _socket: GCDAsyncUdpSocket?
    var socket: GCDAsyncUdpSocket? {
        get {
            if _socket == nil {
                guard let port = UInt16("7700"), port > 0 else {
                    //log(">>> Unable to init socket: local port unspecified.")
                    return nil
                }
                let sock = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
                do {
                    try sock.bind(toPort: port)
                    try sock.beginReceiving()
                } catch let err as NSError {
                    
                    print("Error while initializing socket: \(err.localizedDescription)")
                    sock.close()
                    return nil
                }
                _socket = sock
            }
            return _socket
        }
        set {
            _socket?.close()
            _socket = newValue
        }
    }
    
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - sensorData: <#sensorData description#>
    ///   - port: <#port description#>
    ///   - host: <#host description#>
    func configure(sensorData: SensorData, port: UInt16, host: String = "localhost") {
        
        self.sensorData = sensorData
        self.port = port
        self.host = host
    }
    
    
    //sends the given data
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - str: <#str description#>
    ///   - timeout: <#timeout description#>
    ///   - tag: <#tag description#>
    func sentMsg(str: String, timeout: TimeInterval = 2, tag: Int = 0) {
        
        socket?.send(str.data(using: String.Encoding.utf8)!, toHost:self.host, port: self.port, withTimeout: timeout, tag: tag)
    }
    
    
    
    /// <#Description#>
    func socketClose() {
        
        socket?.close()
    }
    

    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - onComplete: <#onComplete description#>
    ///   - onFail: <#onFail description#>
    func beginAnalyzing(onComplete: @escaping () -> Void, onFail: @escaping () -> Void) {
        
        if(!validateSocketParameters()){
            
            onFail()
            return
        }
        
        self.sentMsg(str: "hello")
        
        let deadlineTime = DispatchTime.now() + .seconds(Configuration.analyzingDurationSeconds)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            
            self.socketClose()
            onComplete()
        })
    }
    
    
    // Called when the socket has received the requested datagram.
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - sock: <#sock description#>
    ///   - data: <#data description#>
    ///   - address: <#address description#>
    ///   - filterContext: <#filterContext description#>
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        guard let stringData = String(data: data, encoding: String.Encoding.utf8) else {
            
            return // Data received, but cannot be converted to String"
        }
        
        if let nsdata = Data(base64Encoded: stringData, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) {
            
            let arrBytes = nsdata.withUnsafeBytes {
                Array(UnsafeBufferPointer<UInt8>(start: $0, count: nsdata.count/MemoryLayout<UInt8>.size))
            }
            //print("Array: ",arrBytes)
            
            
            let time = ""+arrBytes[0].uInt8ToHex()+""+arrBytes[1].uInt8ToHex()+""+arrBytes[2].uInt8ToHex()
            //print("time ",time.hexToInt())
            
            let data = ""+arrBytes[3].uInt8ToHex()+""+arrBytes[4].uInt8ToHex()
            //print("data ",data.hexToInt())
            
            self.sensorData?.addSample(time: time.hexToInt(), data: data.hexToInt())
        }
    }
    
    
    // Called when the socket is closed.
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - sock: <#sock description#>
    ///   - error: <#error description#>
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?){
        
        print("DID Closed connection")
    }
    
    
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func validateSocketParameters() -> Bool {
        
        if(sensorData != nil && port >= 0 && port <= 65535 && host != ""){
            
            return true
        }
        return false
    }
    
    
    deinit {
        
        socket = nil
        sensorData = nil
        print("Socket :: deinit")
    }
    
    
    // MARK: Singlton
    
    
    struct Static
    {
        static var instance: SocketManager?
    }
    
    
    // Singlton
    class var sharedInstance: SocketManager
    {
        if Static.instance == nil
        {
            Static.instance = SocketManager()
        }
        
        return Static.instance!
    }
    
    
    // Dispose Singlton
    func dispose()
    {
        SocketManager.Static.instance = nil
        print("Disposed Singleton instance")
    }
}
