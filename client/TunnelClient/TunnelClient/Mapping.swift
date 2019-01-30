//
//  Mapping.swift
//  TunnelClient
//
//  Created by gimix on 05/12/15.
//  Copyright © 2015 Bugfender. All rights reserved.
//

import Foundation

class Mapping: NSObject,NSCoding {
    let domainName: String
    let mapHostname: String
    let mapPort: UInt16
    
    init(domainName: String, mapHostname: String, mapPort: UInt16) {
        self.domainName = domainName
        self.mapHostname = mapHostname
        self.mapPort = mapPort
    }
    
    // MARK: NSCoding
    required convenience init?(coder decoder: NSCoder) {
        guard let domainName = decoder.decodeObject(forKey: "domainName") as? String,
            let mapHostname = decoder.decodeObject(forKey: "mapHostname") as? String
            else { return nil }
        
        let mapPort = decoder.decodeInteger(forKey: "mapPort")
        self.init(domainName: domainName, mapHostname: mapHostname, mapPort: UInt16(mapPort))
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.domainName, forKey: "domainName")
        coder.encode(self.mapHostname, forKey: "mapHostname")
        coder.encodeCInt(Int32(self.mapPort), forKey: "mapPort")
    }
}
