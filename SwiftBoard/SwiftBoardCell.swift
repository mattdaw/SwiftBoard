//
//  SwiftBoardCell.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-25.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class SwiftBoardCell : UICollectionViewCell {
    
    let animationKey = "jigglingAnimationKey"
    
    func iconRect() -> CGRect? {
        return nil
    }
    
    func startJiggling() {
        let anim = CABasicAnimation(keyPath:"transform.rotation")
        anim.fromValue = -M_PI / 48
        anim.toValue = M_PI / 48
        anim.autoreverses = true
        anim.duration = 0.2
        anim.repeatCount = HUGE
        anim.timeOffset = CFTimeInterval(Double(arc4random_uniform(100)) / 100.0)
        
        self.layer.addAnimation(anim, forKey:animationKey);
    }
    
    func stopJiggling() {
        self.layer.removeAnimationForKey(animationKey)
    }
}