//
//  ConnectionWizardViewController.swift
//  TunnelClient
//
//  Created by gimix on 06/12/15.
//  Copyright © 2015 Bugfender. All rights reserved.
//

import Cocoa
import GoogleAnalyticsTracker

class ConnectionWizardViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var domainStepView: NSView!
    @IBOutlet weak var mappingStepView: NSView!
    var step = 0
    
    @IBOutlet weak var domainPrefixTextField: NSTextField!
    @IBOutlet weak var step1ProTipTextField: NSTextField!
    @IBOutlet weak var domainAvailabilityImageView: NSImageView!
    
    @IBOutlet weak var step2DetailTextField: NSTextField!
    @IBOutlet weak var mappingHostTextField: NSTextField!
    @IBOutlet weak var mappingPortTextField: NSTextField!
    
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var previousButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.view.frame.size.width = self.domainStepView.frame.width
        self.domainPrefixTextField.delegate = self
        self.domainAvailabilityImageView.isHidden = true
        self.nextButton.isEnabled = false
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.previousButton.isEnabled = false
        MPGoogleAnalyticsTracker.trackScreen("Connection wizard")
    }
    
    @IBAction func goToPrevious(_ sender: AnyObject) {
        if(step == 1) {
            self.domainStepView.isHidden = false
            NSAnimationContext.beginGrouping()
            var newOrigin = self.mappingStepView.frame.origin
            newOrigin.x += self.mappingStepView.frame.size.width
            self.mappingStepView.animator().setFrameOrigin(newOrigin)
            
            newOrigin = self.domainStepView.frame.origin
            newOrigin.x += self.domainStepView.frame.size.width
            self.domainStepView.animator().setFrameOrigin(newOrigin)
            NSAnimationContext.current().completionHandler = {
                self.mappingStepView.isHidden = true
                self.domainPrefixTextField.becomeFirstResponder()
            }
            NSAnimationContext.endGrouping()
            step -= 1
            self.nextButton.title = "Next"
            self.previousButton.isEnabled = false
        }
    }
    
    @IBAction func goToNext(_ sender: AnyObject) {
        let domain = self.domainPrefixTextField.stringValue + "-try.localname.io"
        if(step == 0) {
            self.mappingStepView.isHidden = false
            NSAnimationContext.beginGrouping()
            self.mappingStepView.animator().setFrameOrigin(self.domainStepView.frame.origin)
            var newOrigin = self.domainStepView.frame.origin
            newOrigin.x -= self.domainStepView.frame.size.width
            self.domainStepView.animator().setFrameOrigin(newOrigin)
            NSAnimationContext.current().completionHandler = {
                self.domainStepView.isHidden = true
                self.mappingHostTextField.becomeFirstResponder()
            }
            NSAnimationContext.endGrouping()
            step += 1
            self.nextButton.title = "Finish"
            self.previousButton.isEnabled = true
            self.step2DetailTextField.stringValue = "Traffic to https://\(domain) will be forwarded to:"
        } else {
            let mapHostname = self.mappingHostTextField.stringValue
            let mapPort = UInt16(self.mappingPortTextField.intValue)
            MappingController.sharedInstance().addMappingConnection(domain, mapHostname: mapHostname, mapPort: mapPort)
            MPGoogleAnalyticsTracker.trackEvent(ofCategory: "Usage", action: "Created mapping", label: domain, value: 0, contentDescription: nil, customDimension: nil)
            self.dismiss(sender)
        }
    }
    
    let domainLookupQueue = DispatchQueue(label: "domain-lookup")
    fileprivate func checkDomain() {
        //UIKit
        self.domainAvailabilityImageView.isHidden = true
        self.nextButton.isEnabled = false
        
        let domain = self.domainPrefixTextField.stringValue + "-try.localname.io"
        BFLog("testing domain: \(domain)")
        
        domainLookupQueue.async {
            let semaphore = DispatchSemaphore(value: 0)
            MappingController.sharedInstance().isDomainAvailable(domain) { (available, error) in
                if let error = error {
                    BFLog("Error retrieving domain availability: \(error)")
                    semaphore.signal()
                } else {
                    BFLog("domain: \(domain) is available: \(available!)")
                    DispatchQueue.main.async {
                        if self.domainPrefixTextField.stringValue.characters.count > 0 {
                            //UIKit
                            let imageName = available! ? "ic-connected" : "ic-disconnected"
                            self.domainAvailabilityImageView.image = NSImage(named: imageName)
                            self.domainAvailabilityImageView.isHidden = false
                            self.nextButton.isEnabled = available!
                        }
                        semaphore.signal()
                    }
                }
            }
            semaphore.wait()
        }
    }
    
    // NSTextFieldDelegate
    override func controlTextDidChange(_ obj: Notification) {
        checkDomain()
    }
}
