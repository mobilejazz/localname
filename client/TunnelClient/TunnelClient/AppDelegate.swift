//
//  AppDelegate.swift
//  TunnelClient
//
//  Created by gimix on 22/10/15.
//  Copyright © 2015 Bugfender. All rights reserved.
//

import Cocoa
import GoogleAnalyticsTracker
@_exported import BugfenderSDK

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var windowController: NSWindowController?
    var proxyClient = ProxyClient(socketURL: Configuration.serverSocketURL)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if Configuration.googleAnalyticsTrackingID != nil {
            MPGoogleAnalyticsTracker.activate(MPAnalyticsConfiguration(analyticsIdentifier: Configuration.googleAnalyticsTrackingID!))
            MPGoogleAnalyticsTracker.trackEvent(ofCategory: "Lifecycle", action: "App launch", label: "App launch", value: 0, contentDescription: nil, customDimension: nil)
        }
    
        if Configuration.bugfenderAppKey != nil {
            Bugfender.activateLogger(Configuration.bugfenderAppKey!)
        }
        
        showWindow()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if sender.mainWindow == nil {
            showWindow()
        }
        return true
    }
    
    fileprivate func showWindow() {
        self.windowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "main") as? NSWindowController
        self.windowController!.showWindow(nil)
    }
}

