//
//  SwiftBoardCell.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-25.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class SwiftBoardCell : UICollectionViewCell {
    let jigglingAnimationKey = "jigglingAnimationKey"
    
    func iconRect() -> CGRect? {
        return nil
    }
    
    func startJiggling() {
        self.layer.addAnimation(jigglingAnimation(), forKey:jigglingAnimationKey);
    }
    
    func stopJiggling() {
        self.layer.removeAnimationForKey(jigglingAnimationKey)
    }
    
    func jigglingAnimation() -> CABasicAnimation {
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