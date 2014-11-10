//
//  PanAndStopGestureRecognizer.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-10.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class PanAndStopGestureRecognizer: UIPanGestureRecognizer {
    let stopAfterSecondsWithoutMovement: Double
    
    private var stopTimer: NSTimer?
    private var stopFunction:CGPoint -> ()
    private var lastTranslation:CGPoint
    
    // TODO: Take a block that is called when a "stop" is detected. Pass it the latest position?
    init(target:AnyObject, action:Selector, stopAfterSecondsWithoutMovement stopAfterSeconds:Double, stopFunction stopFn:CGPoint -> ()) {
        stopAfterSecondsWithoutMovement = stopAfterSeconds
        stopFunction = stopFn
        lastTranslation = CGPoint(x:0, y:0)
        super.init(target: target, action: action)
    }
    
    override func touchesMoved(touches:NSSet, withEvent event:UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        stopTimer?.invalidate()
        
        if state == .Began || state == .Changed {
            lastTranslation = translationInView(view!)
            stopTimer = NSTimer.scheduledTimerWithTimeInterval(stopAfterSecondsWithoutMovement, target: self, selector: "callStopFunction", userInfo: nil, repeats: false)
        }
    }
    
    override func reset() {
        super.reset()
        stopTimer?.invalidate()
    }
    
    func callStopFunction() {
        stopFunction(lastTranslation)
    }
}
