//
//  ConnectionTableView.swift
//  TunnelClient
//
//  Created by Jordi Giménez Gámez on 13/01/2017.
//  Copyright © 2017 Bugfender. All rights reserved.
//

import Cocoa

class ConnectionTableView: NSTableView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    override func drawGrid(inClipRect clipRect: NSRect) {
        let lastRowRect = self.rect(ofRow: self.numberOfRows-1)
        let myClipRect = NSMakeRect(0, 0, lastRowRect.size.width, NSMaxY(lastRowRect))
        let finalClipRect = NSIntersectionRect(clipRect, myClipRect)
        super.drawGrid(inClipRect: finalClipRect)
    }
}
