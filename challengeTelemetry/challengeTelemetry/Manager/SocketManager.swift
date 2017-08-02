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
    var host: String = "localhost"
    
    
    
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
                    //log(">>> Error while initializing socket: \(err.localizedDescription)")
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
    
    
    
    override init() {

    }
    
    
    func configure(sensorData: SensorData, port: UInt16, host: String = "localhost") {
        
        self.sensorData = sensorData
        self.port = port
        self.host = host
    }
    
    //sends the given data
    func sentMsg(str: String, timeout: TimeInterval = 2, tag: Int = 0) {
        
        socket?.send(str.data(using: String.Encoding.utf8)!, toHost:self.host, port: self.port, withTimeout: timeout, tag: tag)
    }
    
    
    func socketClose() {
        
        socket?.close()
    }
    

    func beginAnalyzing(onSuccess: @escaping (AnyObject) -> Void , onFailure: @escaping (Error) -> Void) {
        
        self.sentMsg(str: "hello")
        
        
        let deadlineTime = DispatchTime.now() + .seconds(4)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            
            self.socketClose()
            print("end close")
            onSuccess(true as AnyObject)
        })
    }
    
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        guard let stringData = String(data: data, encoding: String.Encoding.utf8) else {
            //log(">>> Data received, but cannot be converted to String")
            return
        }
        //log("Data received: \(stringData)")
        
        
        if let nsdata = Data(base64Encoded: stringData, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) {
            
            let arrBytes = nsdata.withUnsafeBytes {
                Array(UnsafeBufferPointer<UInt8>(start: $0, count: nsdata.count/MemoryLayout<UInt8>.size))
            }
            print("Array: ",arrBytes)
            
            
            let time = ""+arrBytes[0].uInt8ToHex()+""+arrBytes[1].uInt8ToHex()+""+arrBytes[2].uInt8ToHex()
            print("time ",time.hexToInt())
            
            let data = ""+arrBytes[3].uInt8ToHex()+""+arrBytes[4].uInt8ToHex()
            print("data ",data.hexToInt())
            
            self.sensorData?.addSample(time: time.hexToInt(), data: data.hexToInt())
        }
    }
    
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?){
        
        print("DID Closed connection")
    }
    
    
    public func onSocket(_ sock: GCDAsyncUdpSocket, didConnectToHost host: String!, port: UInt16) {
        
        print("DID Connect")
    }
    
    
    
    
    deinit {
        
        socket = nil
        print("Socket :: deinit")

    }
    
    
    // Singlton
    static let sharedInstance : SocketManager = {
        let instance = SocketManager()
        return instance
    }()

}
