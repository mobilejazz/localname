//
//  MappingController.swift
//  TunnelClient
//
//  Created by gimix on 05/12/15.
//  Copyright © 2015 Bugfender. All rights reserved.
//

import Cocoa

class MappingController: NSObject {
    
    fileprivate static var instance: MappingController?
    static func sharedInstance() -> MappingController {
        if instance == nil {
            instance = restoreFromPreferences()
        }
        if instance == nil {
            instance = MappingController()
        }
        return instance!
    }
    
    var mappingConnections = [MappingConnection]()
    
    fileprivate override init() { }
    
    func isDomainAvailable(_ domainName: String, completionHandler: @escaping (Bool?, NSError?)->Void) {
        let proxyClient = (NSApp.delegate as! AppDelegate).proxyClient        
        proxyClient.isAvailable(name: domainName, completionHandler: completionHandler)
    }
    
    func addMappingConnection(_ domainName: String, mapHostname: String, mapPort: UInt16) {
        let mapping = Mapping(domainName: domainName, mapHostname: mapHostname, mapPort: mapPort)
        self.addMappingConnection(mapping)
    }

    func addMappingConnection(_ mapping: Mapping) {
        let mappingConnection = MappingConnection(mapping: mapping)
        mappingConnections.append(mappingConnection)
        mappingConnection.connect()
        self.saveToPreferences()
    }

    func removeMappingConnection(_ mappingConnection: MappingConnection) {
        self.mappingConnections.enumerated().forEach { (index, element) -> () in
            if(element == mappingConnection) {
                element.disconnect()
                self.mappingConnections.remove(at: index)
            }
        }
        self.saveToPreferences()
    }
    
    func allMappings() -> [Mapping] {
        return mappingConnections.map({$0.mapping})
    }
    
    internal func saveToPreferences() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self.allMappings())
        UserDefaults.standard.set(data, forKey: "mappings")
    }
    
    static func restoreFromPreferences() -> MappingController? {
        if let data = UserDefaults.standard.object(forKey: "mappings") as? Data {
            if let mappings = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Mapping] {
                let mc = MappingController()
                mappings.forEach({ mc.addMappingConnection($0) })
                return mc
            }
        }
        return nil
    }
}
