//
//  RoundedButton.swift
//  TunnelClient
//
//  Created by Jordi Giménez Gámez on 13/01/2017.
//  Copyright © 2017 Bugfender. All rights reserved.
//

import Cocoa

@IBDesignable
class RoundedButtonCell: NSButtonCell {
    
    @IBInspectable var radius: CGFloat = 0.0
    @IBInspectable var borderColor: NSColor?

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        if let bc = borderColor {
            let border = NSBezierPath(roundedRect: NSInsetRect(cellFrame, 1, 1), xRadius: radius, yRadius: radius)
            border.lineWidth = 1.5
            bc.setStroke()
            border.stroke()
        }
        self.state = NSOnState
        
        let insetRect = NSInsetRect(cellFrame, 0.4*radius, 0.4*radius)
        super.draw(withFrame: insetRect, in: controlView)
    }
    
}
