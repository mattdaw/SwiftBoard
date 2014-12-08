//
//  AppCollectionViewCell.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-18.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class AppCollectionViewCell : ItemViewModelCell, AppViewModelDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    weak var appViewModel: AppViewModel? {
        didSet {
            if let myViewModel = appViewModel {
                hidden = myViewModel.dragging
                editing = myViewModel.editing
                zoomed = myViewModel.zoomed
                label.text = myViewModel.name
                containerView.backgroundColor = myViewModel.color
                myViewModel.delegate = self
            } else {
                hidden = false
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        appViewModel = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 5
        deleteButton.layer.cornerRadius = 11
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        super.applyLayoutAttributes(layoutAttributes)
        
        if zoomed {
            updateConstraintsZoomed()
        } else if bounds.width < 80 {
            updateConstraintsSmall()
        } else {
            updateConstraintsNormal()
        }
        
        // Trigger constraint re-evaluation, so the subview sizes get animated too
        // http://stackoverflow.com/questions/23564453/uicollectionview-layout-transitions
        layoutIfNeeded()
    }
    
    @IBAction func deleteApp(sender: AnyObject) {
        appViewModel?.delete()
    }
    
    override func iconRect() -> CGRect? {
        return containerView.frame
    }
    
    override func showDeleteButton(animated: Bool) {
        deleteButton.hidden = false
        
        if animated {
            deleteButton.transform = CGAffineTransformMakeScale(0.01, 0.01)
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.deleteButton.transform = CGAffineTransformIdentity
            })
        }
    }
    
    override func hideDeleteButton(animated: Bool) {
        if animated {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.deleteButton.transform = CGAffineTransformMakeScale(0.01, 0.01)
            }, completion: { (finished: Bool) -> Void in
                self.deleteButton.hidden = true
                self.deleteButton.transform = CGAffineTransformIdentity
            })
        } else {
            self.deleteButton.hidden = true
        }
    }
    
    func updateConstraintsZoomed() {
        topConstraint.constant = 10
        bottomConstraint.constant = 30
        leftConstraint.constant = 10
        rightConstraint.constant = 10
    }
    
    func updateConstraintsSmall() {
        deleteButton.alpha = 0
        label.alpha = 0
        
        topConstraint.constant = 2
        bottomConstraint.constant = 2
        leftConstraint.constant = 2
        rightConstraint.constant = 2
    }
    
    func updateConstraintsNormal() {
        deleteButton.alpha = 1
        label.alpha = 1
        
        let extraWidth = (bounds.width - 60) / 2
        let extraHeight = (bounds.height - 80) / 2
        
        topConstraint.constant = extraHeight
        bottomConstraint.constant = extraHeight + 20
        leftConstraint.constant = extraWidth
        rightConstraint.constant = extraWidth

    }
    
    // MARK: AppViewModelDelegate
    
    func appViewModelDraggingDidChange(newValue: Bool) {
        hidden = newValue
    }
    
    func appViewModelDeletingDidChange(newValue: Bool) {
        if newValue {
            let op = FadeOutCellOperation(self)
            NSOperationQueue.mainQueue().addOperation(op)
        }
    }
    
    func appViewModelEditingDidChange(newValue: Bool) {
        editing = newValue
    }
    
    func appViewModelZoomedDidChange(newValue: Bool) {
        zoomed = newValue
    }
}
