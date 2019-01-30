//
//  MenuController.swift
//  TunnelClient
//
//  Created by Jordi Giménez Gámez on 01/03/2017.
//  Copyright © 2017 Bugfender. All rights reserved.
//

import Cocoa
import GoogleAnalyticsTracker

class MenuController: NSObject {
    @IBAction func showHelp(_ sender: Any) {
        let url = URL(string: "https://github.com/mobilejazz/localname")!
        NSWorkspace.shared().open(url)
        MPGoogleAnalyticsTracker.trackEvent(ofCategory: "Menu", action: "Help", label: "Help", value: 0, contentDescription: nil, customDimension: nil)
    }

    @IBAction func showBugfender(_ sender: Any) {
        let url = URL(string: "https://bugfender.com/?utm_source=localname&utm_medium=menu&utm_campaign=localname&utm_content=menu1")!
        NSWorkspace.shared().open(url)
        MPGoogleAnalyticsTracker.trackEvent(ofCategory: "Menu", action: "Related", label: "Bugfender", value: 0, contentDescription: nil, customDimension: nil)
    }
    @IBAction func showEnterprisePush(_ sender: Any) {
        let url = URL(string: "https://mobilejazz.com/products/enterprise-push-technology?utm_source=localname&utm_medium=menu&utm_campaign=localname&utm_content=menu1")!
        NSWorkspace.shared().open(url)
        MPGoogleAnalyticsTracker.trackEvent(ofCategory: "Menu", action: "Related", label: "Enterprise push", value: 0, contentDescription: nil, customDimension: nil)
    }
    @IBAction func showOpenSource(_ sender: Any) {
        let url = URL(string: "https://mobilejazz.com/products/opensource?utm_source=localname&utm_medium=menu&utm_campaign=localname&utm_content=menu1")!
        NSWorkspace.shared().open(url)
        MPGoogleAnalyticsTracker.trackEvent(ofCategory: "Menu", action: "Related", label: "Open source", value: 0, contentDescription: nil, customDimension: nil)
    }
}
