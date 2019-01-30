//
//  ConnectionViewController.swift
//  TunnelClient
//
//  Created by gimix on 05/12/15.
//  Copyright © 2015 Bugfender. All rights reserved.
//

import Cocoa
import GoogleAnalyticsTracker

class ConnectionViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    var mappingConnections = [MappingConnection]()
    var screenUpdateTimer: Timer?
    
    @IBOutlet weak var buyPremiumLicenseButton: NSButton!
    @IBOutlet weak var timeLeftButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!

    var expiryDate: Date
    
    public required init(coder: NSCoder) {
        expiryDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        super.init(coder: coder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.selectionHighlightStyle = .none

        screenUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ConnectionViewController.update), userInfo: nil, repeats: true)
        
//        self.buyPremiumLicenseButton.attributedTitle = { () -> NSAttributedString in
//            let style = NSMutableParagraphStyle()
//            style.alignment = .center
//            //NSForegroundColorAttributeName: NSColor(red: 0, green: 1, blue: 0, alpha: 1),
//            let attrs = [ NSParagraphStyleAttributeName: style,
//                          NSFontAttributeName: NSFont.boldSystemFont(ofSize: NSFont.systemFontSize()) ]
//            return NSAttributedString(string: "Buy premium license", attributes: attrs)
//        }()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        MPGoogleAnalyticsTracker.trackScreen("Connection list")
    }
    
    internal func update() {
        self.mappingConnections = MappingController.sharedInstance().mappingConnections
        self.tableView.reloadData()
        
//        let timeLeftAttributedString = { () -> NSAttributedString in
//            let style = NSMutableParagraphStyle()
//            style.alignment = .center
//            let attrs = [ NSForegroundColorAttributeName: NSColor(white: 0.8, alpha: 1.0),
//                          NSParagraphStyleAttributeName: style ]
//            return NSAttributedString(string: "Free time left: ", attributes: attrs)
//        }()
//
//        let minutesAttributtedString = { () -> NSAttributedString in
//            let style = NSMutableParagraphStyle()
//            style.alignment = .center
//            let attrs = [ NSForegroundColorAttributeName: NSColor(white: 0.8, alpha: 1.0),
//                          NSParagraphStyleAttributeName: style,
//                          NSFontAttributeName: NSFont.boldSystemFont(ofSize: NSFont.systemFontSize()) ]
//            let minutesString = TimeIntervalFormatter().minutesSeconds(from: self.expiryDate.timeIntervalSinceNow).appending(" minutes")
//            return NSAttributedString(string: minutesString, attributes: attrs)
//        }()
        
//        let buttonTitle = NSMutableAttributedString()
//        buttonTitle.append(timeLeftAttributedString)
//        buttonTitle.append(minutesAttributtedString)
//
//        self.timeLeftButton.attributedTitle = buttonTitle
    }
    
    internal func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.mappingConnections.count
    }
    
    internal func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        
        let mappingConnection = self.mappingConnections[row]
        if tableColumn!.identifier == "Domain" {
            cellView.textField!.stringValue = mappingConnection.mapping.domainName
        } else if tableColumn!.identifier == "Map" {
            cellView.textField!.stringValue = mappingConnection.mapping.mapHostname + ":" + String(mappingConnection.mapping.mapPort)
        } else if tableColumn!.identifier == "Status" {
            cellView.textField!.stringValue = mappingConnection.connectionStatus.rawValue
            var imageName: String {
                switch mappingConnection.connectionStatus {
                case .Connected:
                    return "ic-connected"
                case .Connecting:
                    return "ic-clock"
                case .Disconnected:
                    return "ic-disconnected"
                case .Disconnecting:
                    return "ic-clock"
                }
            }
            cellView.imageView!.image = NSImage(named: imageName)
            let goButton = (cellView as! WithDeleteCellView).goButton
            goButton?.target = self
            goButton?.action = #selector(ConnectionViewController.goToMapping(_:))
            goButton?.tag = row
            let deleteButton = (cellView as! WithDeleteCellView).deleteButton
            deleteButton?.target = self
            deleteButton?.action = #selector(ConnectionViewController.deleteMapping(_:))
            deleteButton?.tag = row
        }
//        tableColumn!.headerCell = ConnectionTableHeaderCell(textCell: tableColumn!.identifier)
        
        return cellView
    }
    
    internal func deleteMapping(_ sender: NSButton) {
        let mappingConnection = self.mappingConnections[sender.tag]
        let confirmationDialog = NSAlert()
        confirmationDialog.messageText = "Delete \(mappingConnection.mapping.domainName) domain?"
        confirmationDialog.informativeText = "Are you sure you want to delete this domain?"
        confirmationDialog.alertStyle = .warning
        confirmationDialog.addButton(withTitle: "Delete")
        confirmationDialog.addButton(withTitle: "Cancel")
        let response = confirmationDialog.runModal()
        if(response == NSAlertFirstButtonReturn) {
            MappingController.sharedInstance().removeMappingConnection(mappingConnection)
            self.update()
        }
    }
    
    internal func goToMapping(_ sender: NSButton) {
        let mappingConnection = self.mappingConnections[sender.tag]
        let url = URL(string: "https://" + mappingConnection.mapping.domainName)!
        NSWorkspace.shared().open(url)
    }
}
