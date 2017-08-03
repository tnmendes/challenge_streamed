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
                // Random local port
                guard let port = UInt16(Configuration.localPort), port > 0 else {
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
    
    
    /// Mandatory settings for the running of the socket
    ///
    /// - Parameters:
    ///   - sensorData: Object of SensorData that will be filled
    ///   - port: server port
    ///   - host: server host name or IP
    func configure(sensorData: SensorData, port: UInt16, host: String = "localhost") {
        
        self.sensorData = sensorData
        self.port = port
        self.host = host
    }
    
    
    /// Sends the given data to the server by UDP
    ///
    /// - Parameters:
    ///   - str: string to be send
    ///   - timeout: how much time until give up
    ///   - tag: The tag is for your convenience, can use it as an array index, state id.
    func sentMsg(str: String, timeout: TimeInterval = 2, tag: Int = 0) {
        
        socket?.send(str.data(using: String.Encoding.utf8)!, toHost:self.host, port: self.port, withTimeout: timeout, tag: tag)
    }
    
    
    /// Terminates with socket connection
    ///
    func socketClose() {
        
        socket?.close()
    }
    
    
    /// This function does everything necessary to trigger the process to connect to the server and after to terminate socket
    ///
    /// - Parameters:
    ///   - onComplete: event released in success
    ///   - onFail: event released if some parameter are missing
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
    
    
    // MARK: Delegate

    
    /// Called when the socket has received the requested datagram.
    /// Delegate from CocoaAsyncSocket.
    ///
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
    
    
    /// Called when the socket is closed.
    /// Delegate from CocoaAsyncSocket.
    ///
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?){}
    
    
    
    /// Validator of the fields in the configurations to check if they exist and if they are correct.
    ///
    /// - Returns: Bool
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
    }
}
