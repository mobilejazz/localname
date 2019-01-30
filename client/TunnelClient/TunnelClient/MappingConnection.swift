//
//  MappingConnection.swift
//  TunnelClient
//
//  Created by gimix on 07/12/15.
//  Copyright © 2015 Bugfender. All rights reserved.
//

import Cocoa

class MappingConnection: NSObject {
    let mapping: Mapping
    var connectionStatus = ConnectionStatus.Disconnected
    var bytesTransmitted = 0
    var activeConnections = 0
    
    enum ConnectionStatus: String {
        case Connected,
        Disconnected,
        Connecting,
        Disconnecting
    }
    
    init(mapping: Mapping) {
        self.mapping = mapping
    }
    
    func connect() {
        let proxyClient = (NSApp.delegate as! AppDelegate).proxyClient
        proxyClient.add(self)
    }
    
    func disconnect() {
        let proxyClient = (NSApp.delegate as! AppDelegate).proxyClient
        proxyClient.remove(self)
    }
}
