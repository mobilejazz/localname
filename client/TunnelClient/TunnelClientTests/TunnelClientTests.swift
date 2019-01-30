//
//  TunnelClientTests.swift
//  TunnelClientTests
//
//  Created by gimix on 22/10/15.
//  Copyright © 2015 Bugfender. All rights reserved.
//

import XCTest
import Socket_IO_Client_Swift
@testable import TunnelClient

class TunnelClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testSocketIO() {
        let socket = SocketIOClient(socketURL: "localhost:1235", options: [.log(true), .forcePolling(true)])
        
        socket.on("connect") {data, ack in
            let data = Data()
            socket.emit("boom", ["x":data])
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
