//
//  FolderCollectionViewCell.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-18.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderCollectionViewCell : SwiftBoardCell, FolderViewModelDelegate {
    @IBOutlet weak var collectionView: FolderCollectionView!
    @IBOutlet weak var expandingView: UIView!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    let flickeringAnimationKey = "flickering"
    
    private var opened = false
    private var expanded: Bool = false {
        didSet {
            expanded ? expand() : collapse()
        }
    }
    
    private var flickering: Bool = false {
        didSet {
            flickering ? startFlickering() : stopFlickering()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.backgroundColor = UIColor.clearColor()
        expandingView.layer.cornerRadius = 5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        hidden = false
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        super.applyLayoutAttributes(layoutAttributes)
    
        if opened {
            topConstraint.constant = 10
            bottomConstraint.constant = 30
            leftConstraint.constant = 10
            rightConstraint.constant = 10
        } else {
            let extraWidth = (bounds.width - 60) / 2
            let extraHeight = (bounds.height - 80) / 2
            
            topConstraint.constant = extraHeight
            bottomConstraint.constant = extraHeight + 20
            leftConstraint.constant = extraWidth
            rightConstraint.constant = extraWidth
        }
        
        // Trigger constraint re-evaluation, so the subview sizes get animated too
        // http://stackoverflow.com/questions/23564453/uicollectionview-layout-transitions
        layoutIfNeeded()
    }
    
    override func iconRect() -> CGRect? {
        return collectionView.frame
    }
    
    func expand() {
        UIView.animateWithDuration(0.4) {
            self.expandingView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
            self.label.alpha = 0
        }
    }
    
    func collapse() {
        UIView.animateWithDuration(0.4) {
            self.expandingView.layer.transform = CATransform3DIdentity
            self.label.alpha = 1
        }
    }
    
    func configureForFolderViewModel(folderViewModel: FolderViewModel) {
        hidden = folderViewModel.dragging
        label.text = folderViewModel.name
        collectionView.folderViewModel = folderViewModel
        
        folderViewModel.itemViewModelDelegate = self
    }
    
    func startFlickering() {
        let anim = CABasicAnimation(keyPath: "backgroundColor")
        anim.toValue = UIColor.darkGrayColor().CGColor
        anim.autoreverses = true
        anim.duration = 0.1
        anim.repeatCount = HUGE
        
        expandingView.layer.addAnimation(anim, forKey:flickeringAnimationKey);
    }
    
    func stopFlickering() {
        expandingView.layer.removeAnimationForKey(flickeringAnimationKey)
    }

    // FolderViewModelDelegate
    
    func folderViewModelDraggingDidChange(dragging: Bool) {
        hidden = dragging
    }
    
    func folderViewModelStateDidChange(state: FolderViewModelState) {
        switch state {
        case .Closed:
            opened = false
            expanded = false
            flickering = false
        case .AppHovering:
            opened = false
            expanded = true
            flickering = false
        case .PreparingToOpen:
            opened = false
            expanded = true
            flickering = true
        case .Open:
            opened = true
            expanded = false
            flickering = false
        default:
            break;
        }
    }
}
