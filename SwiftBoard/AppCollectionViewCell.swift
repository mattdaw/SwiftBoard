//
//  AppCollectionViewCell.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-18.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class AppCollectionViewCell : SwiftBoardCell, AppViewModelDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 5
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        super.applyLayoutAttributes(layoutAttributes)
        
        if bounds.width < 40 {
            deleteButton.alpha = 0
            label.alpha = 0
            topConstraint.constant = 0
            bottomConstraint.constant = 0
            leftConstraint.constant = 0
            rightConstraint.constant = 0
        } else {
            deleteButton.alpha = 1
            label.alpha = 1
            topConstraint.constant = 8
            bottomConstraint.constant = 28
            leftConstraint.constant = 18
            rightConstraint.constant = 18
        }
        
        // Trigger constraint re-evaluation, so the subview sizes get animated too
        // http://stackoverflow.com/questions/23564453/uicollectionview-layout-transitions
        layoutIfNeeded()
    }
    
    override func pointInsideIcon(point:CGPoint) -> Bool {
        let converted = convertPoint(point, toView:containerView)
        return containerView.pointInside(converted, withEvent: nil)
    }
    
    // AppViewModelDelegate
    func appViewModelDraggingDidChange(dragging: Bool) {
        if dragging {
            alpha = 0
        } else {
            alpha = 1
        }
    }
}
