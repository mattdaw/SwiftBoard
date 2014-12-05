//
//  Extensions.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-24.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

extension Int {
    func toIndexPath() -> NSIndexPath {
        return NSIndexPath(forItem: self, inSection: 0)
    }
}

extension CABasicAnimation {
    class func jigglingAnimation() -> CABasicAnimation {
        let anim = CABasicAnimation(keyPath:"transform.rotation")
        anim.fromValue = -M_PI / 48
        anim.toValue = M_PI / 48
        anim.autoreverses = true
        anim.duration = 0.2
        anim.repeatCount = HUGE
        anim.timeOffset = CFTimeInterval(Double(arc4random_uniform(100)) / 100.0)

        return anim
    }
}