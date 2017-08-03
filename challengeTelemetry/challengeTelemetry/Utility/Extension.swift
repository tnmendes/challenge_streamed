//
//  Extension.swift
//  challengeTelemetry
//
//  Created by Tiago Mendes on 02/08/2017.
//  Copyright © 2017 Tiago Mendes. All rights reserved.
//

import Foundation
import UIKit



extension String {
    
    //: ### Base64 encoding a string
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    public func hexToInt() -> Int {
        
        return Int(self, radix: 16)!
    }
}



extension UInt8 {
    
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    public func uInt8ToHex() -> String {
        
        return String(self, radix: 16)
    }
}


extension UIViewController {
    
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
