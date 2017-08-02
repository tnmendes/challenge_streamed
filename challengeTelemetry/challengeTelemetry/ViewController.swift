//
//  ViewController.swift
//  challengeTelemetry
//
//  Created by Tiago Mendes on 01/08/2017.
//  Copyright © 2017 Tiago Mendes. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController, GCDAsyncUdpSocketDelegate {

    
    var _socket: GCDAsyncUdpSocket?
    var socket: GCDAsyncUdpSocket? {
        get {
            if _socket == nil {
                guard let port = UInt16("7700" ), port > 0 else {
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

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        let str = "hello"
        //socket?.send(str.data(using: String.Encoding.utf8)!, toHost:"localhost", port: 8501, withTimeout: 2, tag: 0)
        print("Data sent: \(str)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        guard let stringData = String(data: data, encoding: String.Encoding.utf8) else {
            //log(">>> Data received, but cannot be converted to String")
            return
        }
        //log("Data received: \(stringData)")
        
        
        if let nsdata1 = Data(base64Encoded: stringData, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) {
            
            let arr2 = nsdata1.withUnsafeBytes {
                Array(UnsafeBufferPointer<UInt8>(start: $0, count: nsdata1.count/MemoryLayout<UInt8>.size))
            }
            print("Array: ",arr2)
            
            
            let data2 = ""+arr2[0].uInt8ToHex()+""+arr2[1].uInt8ToHex()+""+arr2[2].uInt8ToHex()
            print("time ",data2.hexToInt())
            
            
            let data = ""+arr2[3].uInt8ToHex()+""+arr2[4].uInt8ToHex()
            print("data ",data.hexToInt())
        }
    }

}






