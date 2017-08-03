//
//  challengeTelemetryTests.swift
//  challengeTelemetryTests
//
//  Created by Tiago Mendes on 01/08/2017.
//  Copyright © 2017 Tiago Mendes. All rights reserved.
//

import XCTest
import CocoaAsyncSocket

@testable import challengeTelemetry

class challengeTelemetryTests: XCTestCase {
    
    let arraySamples = [[1,100],[2,200],[3,300],[4,400],[5,500],]
    
    
    // Test with a list of known data the returned values
    func testSensorData() {
        
        let sensorData = SensorData(period: Configuration.defaultPeriod)
        
        for sample in arraySamples {
            
            sensorData.addSample(time: sample[0], data: sample[1])
        }

        XCTAssertEqual(500, sensorData.getMaximum())
        XCTAssertEqual(100, sensorData.getMinimum())
        XCTAssertEqual(300, sensorData.getMovingAverage)
        XCTAssertEqual(arraySamples.count, sensorData.getSampleCount())
    }
    
    
    // Check how the class behaves without data
    func testSensorDataEmpty() {
        
        let sensorData = SensorData(period: Configuration.defaultPeriod)
        
        XCTAssertNotEqual(Int.max, sensorData.getMaximum())
        XCTAssertNotEqual(Int.min, sensorData.getMinimum())
        XCTAssertEqual(0, sensorData.getMovingAverage)
        XCTAssertEqual(0, sensorData.getSampleCount())
    }
    
    
    // Test that we can open socket and receive values.
    // Requirements: it is necessary that python server is working (port: 8501, host: localhost)
    func testSocketManager() {
        // Given
        let expectation = self.expectation(description: "request should succeed")
        let sensorData = SensorData(period: Configuration.defaultPeriod)
        let socket = SocketManager.sharedInstance
        socket.configure(sensorData: sensorData, port: UInt16(8501), host: "localhost")
        
        // When
        socket.beginAnalyzing(onComplete: {_ in
            
            expectation.fulfill()
        }, onFail: {_ in
            
            XCTFail()
        })
        
        // Then
        waitForExpectations(timeout: TimeInterval( Configuration.analyzingDurationSeconds+5), handler: nil)
        XCTAssertNotEqual(0, sensorData.getSampleCount())
        XCTAssertNotEqual(Int.min, sensorData.getMaximum())
        XCTAssertNotEqual(Int.max, sensorData.getMinimum())

        socket.dispose()
    }
    
}
