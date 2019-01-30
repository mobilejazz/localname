//
//  Configuration.swift
//  TunnelClient
//
//  Created by gimix on 07/12/15.
//  Copyright © 2015 Bugfender. All rights reserved.
//

import Cocoa

class Configuration: NSObject {
    static let serverSocketURL = URL(string: "http://YOUR_SERVER_URL:1235")!
    static let googleAnalyticsTrackingID: String? = nil // get a key at analytics.google.com
    static let bugfenderAppKey: String? = nil // get a key at bugfender.com
}
