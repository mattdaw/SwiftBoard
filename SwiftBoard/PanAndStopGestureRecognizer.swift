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
    private var stopFunction:PanAndStopGestureRecognizer -> ()
    private var lastLocation:CGPoint
    
    init(target:AnyObject, action:Selector, stopAfterSecondsWithoutMovement stopAfterSeconds:Double, stopFunction stopFn:PanAndStopGestureRecognizer -> ()) {
        stopAfterSecondsWithoutMovement = stopAfterSeconds
        stopFunction = stopFn
        lastLocation = CGPoint(x:0, y:0)
        
        super.init(target: target, action: action)
    }
    
    override func touchesMoved(touches:NSSet, withEvent event:UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        stopTimer?.invalidate()
        
        if state == .Began || state == .Changed {
            lastLocation = locationInView(view!)
            stopTimer = NSTimer.scheduledTimerWithTimeInterval(stopAfterSecondsWithoutMovement, target: self, selector: "callStopFunction", userInfo: nil, repeats: false)
        }
    }
    
    override func reset() {
        super.reset()
        stopTimer?.invalidate()
    }
    
    func callStopFunction() {
        stopFunction(self)
    }
}
