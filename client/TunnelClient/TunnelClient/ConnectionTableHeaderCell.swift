//
//  ConnectionTableHeaderCell.swift
//  TunnelClient
//
//  Created by Jordi Giménez Gámez on 13/01/2017.
//  Copyright © 2017 Bugfender. All rights reserved.
//

import Cocoa

// discussion: http://stackoverflow.com/questions/32666795/how-do-i-override-layout-of-nstableheaderview

class ConnectionTableHeaderCell: NSTableHeaderCell {
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView)
    {
        // background
        NSColor(white: 0.5, alpha: 1.0).setFill()
        NSRectFill(cellFrame)

        // title
        let attrs = [ NSForegroundColorAttributeName: NSColor.white,
                      NSFontAttributeName: NSFont.systemFont(ofSize: 13) ]
        NSAttributedString(string: self.stringValue, attributes: attrs).draw(in: NSInsetRect(cellFrame, 2, 2))
    }
}
