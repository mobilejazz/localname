//
//  HTTPClient.swift
//  Localname
//
//  Created by Jordi Giménez Gámez on 09/06/2017.
//  Copyright © 2017 Bugfender. All rights reserved.
//

import Foundation

public class HTTPClient {
    let addr: String
    let port: Int
    let tcpClient: TCPClient
    var hostHeaderReplaced: Bool = false

    public init(addr a:String,port p:Int){
        self.addr=a
        self.port=p
        self.tcpClient = TCPClient(addr: a, port: p)
    }
    
    /*
     * connect to server
     * return success or fail with message
     */
    public func connect(timeout t:Int)->(Bool,String){
        return self.tcpClient.connect(timeout: t)
    }
    /*
     * close socket
     * return success or fail with message
     */
    public func close()->(Bool,String){
        return self.tcpClient.close()
    }
    /*
     * send data
     * return success or fail with message
     */
    public func send(data d:[UInt8])->(Bool,String){
        var dmutable = d
        if !self.hostHeaderReplaced {
            if let range = self.findHostHeader(d) {
                let newHost = [UInt8]("Host: \(self.addr):\(self.port)".utf8)
                dmutable.replaceSubrange(range, with: newHost)
            }
            self.hostHeaderReplaced = true
        }
        return self.tcpClient.send(data: dmutable)
    }
    /*
     * read data with expect length
     * return success or fail with message
     */
    public func read(expectlen:Int)->[UInt8]?{
        return self.tcpClient.read(expectlen: expectlen)
    }
    
    public func shutdown()->Bool {
        return self.tcpClient.shutdown()
    }
    
    public func onData(callback: @escaping (NSData)->Void) {
        return self.tcpClient.onData(callback: callback)
    }
    
    public func onClose(callback: @escaping ()->Void) {
        return self.tcpClient.onClose(callback: callback)
    }
    
    /**
     * @returns Range where Host: header occurs, including Host: but not including leading or trailing newlines
     */
    private func findHostHeader(_ d: [UInt8])->Range<Int>? {
        //TODO: This implementation assumes the whole line is in the same buffer. It's quite safe since the Host: header is usually the second line
        let pattern: [UInt8] = Array("\r\nHost:".utf8)
        for start in 0..<d.count {
            var matchedIndex: Int = 0
            // check if matches
            while matchedIndex < pattern.count && start+matchedIndex < d.count && d[start+matchedIndex] == pattern[matchedIndex] {
                matchedIndex = matchedIndex + 1
            }
            // if matches
            if matchedIndex == pattern.count {
                // look for next end of line
                let CR = UInt8("\r".unicodeScalars.first!.value) // I can do this because I know this is ASCII
                while start+matchedIndex < d.count && d[start+matchedIndex] != CR {
                    matchedIndex = matchedIndex + 1
                }
                // if found
                if start+matchedIndex < d.count {
                    return start+2..<start+matchedIndex
                }
            }
        }
        return nil
    }
}
