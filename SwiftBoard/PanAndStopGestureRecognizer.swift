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
    var stopTimer: NSTimer?
    
    init(target:AnyObject, action:Selector, stopAfterSecondsWithoutMovement stopAfterSeconds:Double) {
        stopAfterSecondsWithoutMovement = stopAfterSeconds
        super.init(target: target, action: action)
    }
    
    override func touchesMoved(touches:NSSet, withEvent event:UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        stopTimer?.invalidate()
        
        if state == .Began || state == .Changed {
            stopTimer = NSTimer.scheduledTimerWithTimeInterval(stopAfterSecondsWithoutMovement, target: self, selector: "stopGesture", userInfo: nil, repeats: false)
        }
    }
    
    override func reset() {
        super.reset()
        stopTimer?.invalidate()
    }
    
    func stopGesture() {
        state = .Ended
    }
}
