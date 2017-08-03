//
//  ViewController.swift
//  challengeTelemetry
//
//  Created by Tiago Mendes on 01/08/2017.
//  Copyright © 2017 Tiago Mendes. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController {

    
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        portTextField.keyboardType = UIKeyboardType.numberPad
        self.hideKeyboardWhenTappedAround()
    }
    
    
    /// This will be the event that will start the entire UDP connection process
    @IBAction func beginAnalyzing() {
        
        if (Int(self.portTextField.text!)! <= 0 || Int(self.portTextField.text!)! > 65535){
            
            self.alert(message: "The port value must be between 0 and 65535")
            return
        }
        
        let sensorData = SensorData(period: Configuration.defaultPeriod)
        self.statusLabel.text = "Analyzing..."

        
        DispatchQueue.global(qos: .default).async {
            
            let socket = SocketManager.sharedInstance
            socket.configure(sensorData: sensorData, port: UInt16(self.portTextField.text!)!, host: self.hostTextField.text!)
            
            socket.beginAnalyzing(onComplete: {_ in
                
                self.reloadLabels(sensorData: sensorData)
                socket.dispose()
            }, onFail: {_ in
                
                DispatchQueue.main.async() {
                    self.alert(message: "Missing some fields")
                }
                socket.dispose()
            })
        }
        
       
    }
    
    
    /// Helper funtion to reload the sensor related labels
    ///
    /// - Parameter sensorData
    func reloadLabels(sensorData: SensorData) {
        
        DispatchQueue.main.async() { //get the main thread todo UI changes
            
            if(sensorData.getSampleCount() == 0){
                
                self.alert(message: "No data return, server is off?")
                self.statusLabel.text = "No data"
                //socket.dispose()
                return
            }
            
            self.statusLabel.text = "Done!"
            self.maxLabel.text = String(sensorData.getMaximum())
            self.minLabel.text = String(sensorData.getMinimum())
            self.avgLabel.text = String(sensorData.getMovingAverage)
        }
      
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}






