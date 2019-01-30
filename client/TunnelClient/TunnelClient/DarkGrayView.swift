//
//  DarkGrayView.swift
//  TunnelClient
//
//  Created by Jordi Giménez Gámez on 13/01/2017.
//  Copyright © 2017 Bugfender. All rights reserved.
//

import Cocoa

@IBDesignable
class DarkGrayView : NSView {
    
    @IBInspectable var backgroundColor: NSColor? {
        
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
}
