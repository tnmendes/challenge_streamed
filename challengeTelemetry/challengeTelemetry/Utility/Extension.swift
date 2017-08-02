//
//  Extension.swift
//  challengeTelemetry
//
//  Created by Tiago Mendes on 02/08/2017.
//  Copyright © 2017 Tiago Mendes. All rights reserved.
//

import Foundation




extension String {
    
    //: ### Base64 encoding a string
    public func hexToInt() -> Int {
        
        return Int(self, radix: 16)!
    }
}



extension UInt8 {
    
    public func uInt8ToHex() -> String {
        
        return String(self, radix: 16)
    }
}
