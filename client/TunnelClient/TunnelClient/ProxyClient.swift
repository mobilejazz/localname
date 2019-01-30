//
//  ProxyClient.swift
//  TunnelClient
//
//  Created by gimix on 22/10/15.
//  Copyright © 2015 Bugfender. All rights reserved.
//

import Foundation
import SocketIO
import GoogleAnalyticsTracker

open class ProxyClient {
    let ProtocolVersion = 1
    
    var socketURL: URL
    var socket: SocketIOClient?
    var domainMap = Dictionary<String, MappingConnection>()
    var disconnected = true
    
    open var connectedClients = 0
    
    init(socketURL: URL) {
        self.socketURL = socketURL
    }
    
    func add(_ mapping: MappingConnection) {
        let domain = mapping.mapping.domainName
        self.domainMap[domain] = mapping
        
        self.sendConnectCommand(mapping)
        
        if(disconnected) {
            connect()
        }
    }
    
    func remove(_ mapping: MappingConnection) {
        let domain = mapping.mapping.domainName
        domainMap.removeValue(forKey: domain)
        
        if(mapping.connectionStatus != .Disconnected) {
            mapping.connectionStatus = .Disconnecting
            self.socket?.emit("unregister", ["domain": domain])
        }
    }
    
    fileprivate func sendConnectCommand(_ mapping: MappingConnection) {
        if let socket = socket {
            mapping.connectionStatus = .Connecting
            socket.emitWithAck("register", ["domain": mapping.mapping.domainName]).timingOut(after: 0) { data in
                mapping.connectionStatus = .Connected
            }
        }
    }
    
    func isAvailable(name: String, completionHandler: @escaping (Bool?, NSError?)->Void) {
        guard let socket = socket else { return completionHandler(nil, NSError(domain: "com.tunnelclient", code: 1)) }
        
        socket.emitWithAck("is-available", ["domain": name]).timingOut(after: 0) { data in
            guard let result = data[0] as? NSDictionary else { return completionHandler(nil, NSError(domain: "com.tunnelclient", code: 1)) }
            guard let available = result["available"] as? Bool else { return completionHandler(nil, NSError(domain: "com.tunnelclient", code: 1)) }
            completionHandler(available, nil)
        }
    }
    
    func connect() {
        disconnected = false
        
        let socket = SocketIOClient(socketURL: self.socketURL, config: [SocketIOClientOption.log(true)])
        self.socket = socket
        var clients = Dictionary<String,(HTTPClient,MappingConnection)>()
        
        socket.on("connect") {data, ack in
            print("socket connected")
            socket.emitWithAck("login", ["protocol_version": self.ProtocolVersion]).timingOut(after: 0) { data in
                self.domainMap.values.forEach({ (mappingConnection) -> () in
                    self.sendConnectCommand(mappingConnection)
                })
            }
        }
        
        socket.on("socket-connect") {data, ack in
            if let json = data[0] as? Dictionary<String,AnyObject> {
                if let domain = json["domain"] as? String {
                    if let id = json["id"] as? String {
                        if let mappingConnection = self.domainMap[domain] {
                            print("connect for domain: \(domain) with id: \(id)")
                            MPGoogleAnalyticsTracker.trackEvent(ofCategory: "Usage", action: "Served connection for mapping", label: domain, value: 0, contentDescription: nil, customDimension: nil)

                            self.connectedClients = self.connectedClients + 1
                            mappingConnection.activeConnections = mappingConnection.activeConnections + 1

                            let client = HTTPClient(addr: mappingConnection.mapping.mapHostname, port: Int(mappingConnection.mapping.mapPort))
                            clients[id] = (client, mappingConnection)
                            client.connect(timeout: 60)
                            client.onData(callback: { (data) -> Void in
                                print("sending bytes for \(id)")
                                socket.emit("socket-send", ["id":id, "data":data])
                                mappingConnection.bytesTransmitted += data.length
                            })
                            client.onClose(callback: { () -> Void in
                                print("closing \(id)")
                                socket.emit("socket-fin", ["id":id])
                            })
                        }
                    }
                }
            }
        }
        
        socket.on("socket-send") {data, ack in
            if let json = data[0] as? Dictionary<String,AnyObject> {
                if let data = json["data"] as? Data {
                    if let id = json["id"] as? String {
                        print("socket-send for socket with id: \(id)")
                        if let (client, mappingConnection) = clients[id] {
                            var asArray = [UInt8](repeating: 0, count: data.count)
                            data.copyBytes(to: &asArray, count: data.count)
                            client.send(data: asArray)
                            mappingConnection.bytesTransmitted += data.count
                        }
                    }
                }
            }
        }
        
        socket.on("socket-fin") {data, ack in
            if let json = data[0] as? Dictionary<String,AnyObject> {
                if let id = json["id"] as? String {
                    print("disconnecting with id: \(id)")
                    if let (client, mappingConnection) = clients[id] {
                        self.connectedClients = self.connectedClients - 1
                        client.shutdown()
                        mappingConnection.activeConnections = mappingConnection.activeConnections - 1
                    }
                }
            }
        }
        
        socket.on("disconnect") {_, _ in
            print("socketio disconnected")
            clients.forEach({_, t in
                let (client, mappingConnection) = t
                client.close()
                mappingConnection.connectionStatus = .Disconnected
            })
            self.connectedClients = 0
        }
        
        socket.on("error") {_, _ in
            print("socketio error")
            self.domainMap.values.forEach { $0.connectionStatus = .Connecting}
        }
        socket.on("reconnect") {_, _ in
            print("socketio reconnect")
        }
        socket.on("reconnectAttempt") {_, _ in
            print("socketio reconnectAttempt")
        }
        
        socket.on("server-message") {data, _ in
            if let json = data[0] as? Dictionary<String,AnyObject> {
                if let text = json["text"] as? String {
                    print("message from server: \(text)")
                    let alert = NSAlert()
                    alert.addButton(withTitle: "OK")
                    alert.messageText = text
                    alert.alertStyle = .warning
                    alert.runModal()
                }
            }
        }
   
        socket.connect()
    }
    
    func disconnect() {
        socket?.disconnect()
        socket = nil
    }
}
