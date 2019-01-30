//
//  TimeIntervalFormatter.swift
//  TunnelClient
//
//  Created by Jordi Giménez Gámez on 13/01/2017.
//  Copyright © 2017 Bugfender. All rights reserved.
//

import Cocoa

class TimeIntervalFormatter: NSObject {

    func minutesSeconds(from interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

}
