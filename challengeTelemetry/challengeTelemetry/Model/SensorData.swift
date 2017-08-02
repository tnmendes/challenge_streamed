//
//  SensorData.swift
//  challengeTelemetry
//
//  Created by Tiago Mendes on 02/08/2017.
//  Copyright © 2017 Tiago Mendes. All rights reserved.
//

import Foundation


class SensorData {

    var samples: [[Int]] = []
    var sampleCount = 0
    var period: Int
    
    
    init(period: Int = 18000) {
        
        self.period = period
    }
    
    
    func addSample(time: Int, data: Int){
        
        sampleCount = sampleCount + 1
        let pos = Int(fmodf(Float(sampleCount), Float(period)))  // (55,40) = 15 || (15,40) = 15
        
        if pos >= samples.count {
            
            samples.append([time, data])
        } else {
            
            samples[pos] = [time, data]
        }
    }
    
    
    var getMovingAverage: Int {
        
        let sum = samples.reduce(0, { $0 + $1[1] })
        /* isto é a mesma coisa
            array.forEach({ sum += $0.value})
            // or
            for element in array {
                sum += element.value
            }*/
 
        if period > samples.count {
            
            return sum / samples.count
        } else {
            
            return sum / period
        }
    }
    
}
