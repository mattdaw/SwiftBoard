//
//  SwiftBoardCell.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-25.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class SwiftBoardCell : UICollectionViewCell {
    
    let animationKey = "editingModeEnabled"
    
    func pointInsideIcon(point:CGPoint) -> Bool {
        return false
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        super.applyLayoutAttributes(layoutAttributes)
        
        /*
        if let myAttributes = layoutAttributes as? CollectionViewLayoutAttributes {
            if myAttributes.editingModeEnabled {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
        */
    }
    
    func startAnimating() {
        let anim = CABasicAnimation(keyPath:"transform.rotation")
        anim.fromValue = -M_PI / 48
        anim.toValue = M_PI / 48
        anim.autoreverses = true
        anim.duration = 0.2
        anim.repeatCount = HUGE
        anim.timeOffset = CFTimeInterval(Double(arc4random_uniform(100)) / 100.0)
        
        self.layer.addAnimation(anim, forKey:animationKey);
    }
    
    func stopAnimating() {
        self.layer.removeAnimationForKey(animationKey)
    }
}