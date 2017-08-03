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
    var max: Int = Int.min
    var min: Int = Int.max
    
    
    /// Initializer
    ///
    /// - Parameter period: The length of points that will be recived (optional)
    init(period: Int = Configuration.defaultPeriod) {
        
        self.period = period
    }
    
    
    /// All samples will be added and processed in this function
    ///
    /// - Parameters:
    ///   - time: <#time description#>
    ///   - data: <#data description#>
    func addSample(time: Int, data: Int){
        
        sampleCount = sampleCount + 1
        let pos = Int(fmodf(Float(sampleCount), Float(period)))  // (55,40) = 15 || (15,40) = 15
        
        if pos >= samples.count {
            
            samples.append([time, data])
        } else {
            
            samples[pos] = [time, data]
        }
        
        if(data > max){
            
            max = data
        }
        
        if(data < min){
            
            min = data
        }
    }
    
    
    
    /// <#Description#>
    var getMovingAverage: Int {
        
        
        let sum = samples.reduce(0, { $0 + $1[1] })
        
        if(sum == 0){
            
            return 0
        }

        if period > samples.count {
            
            return sum / samples.count
        } else {
            
            return sum / period
        }
    }
    
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func getMinimum() -> Int {
        
        return min
    }
    
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func getMaximum() -> Int {
        
        return max
    }
    
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func getSampleCount() -> Int {
        
        return sampleCount
    }
    
    
    deinit {
        
        print("SensorData :: deinit")
    }
    
}
