//
//  CollectionViewLayout.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

protocol CollectionViewLayoutDelegate {
    func sectionAtIndex(section: Int) -> AnyObject?
}

class CollectionViewLayout: UICollectionViewLayout {
    
    var delegate: CollectionViewLayoutDelegate?
    
    let sectionSize = CGFloat(96)
    var sectionFrames: [CGRect] = []
    var numberOfSections = 0
    var zoomScale = CGFloat(1)
    
    override func collectionViewContentSize() -> CGSize {
        if let cv = collectionView {
            return CGSize(width: cv.bounds.size.width * zoomScale, height: cv.bounds.size.height * zoomScale)
        } else {
            return CGSizeZero
        }
    }
    
    override func prepareLayout() {
        if collectionView == nil {
            return
        }
        
        let myCollectionView = collectionView!
        let availableWidth = myCollectionView.bounds.size.width
        let itemsPerRow = Int(floor(availableWidth / sectionSize))
        let zoomedSize = sectionSize * zoomScale
        
        var top = CGFloat(0)
        var left = CGFloat(0)
        var column = 1
        
        sectionFrames = []
        numberOfSections = myCollectionView.numberOfSections()
        
        for sectionIndex in 0..<numberOfSections {
            let sectionFrame = CGRect(x: left, y: top, width: zoomedSize, height: zoomedSize)
            sectionFrames.append(sectionFrame)
            
            column += 1
            if column > itemsPerRow {
                column = 1
                left = CGFloat(0)
                top += zoomedSize
            } else {
                left += zoomedSize
            }
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        if let myCollectionView = collectionView {
            for sectionIndex in 0..<numberOfSections {
                let numberOfItems = myCollectionView.numberOfItemsInSection(sectionIndex)
                for itemIndex in 0..<numberOfItems {
                    let indexPath = NSIndexPath(forItem: itemIndex, inSection: sectionIndex)
                    attributes.append(layoutAttributesForItemAtIndexPath(indexPath))
                }
            }
        }
        
        return attributes;
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let sectionAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        let sectionIndex = indexPath.section;
        let section: AnyObject? = delegate?.sectionAtIndex(sectionIndex);
        
        if let app = section as? App {
            let sectionFrame = sectionFrames[sectionIndex]
            sectionAttributes.frame = sectionFrame
        } else if let folder = section as? Folder {
            if indexPath.item < 9 {
                let row = floor(CGFloat(indexPath.item / 3))
                let column = CGFloat(indexPath.item % 3)
                let sectionFrame = sectionFrames[sectionIndex]
                let appSize = sectionSize * zoomScale / 3;
                
                let left = sectionFrame.origin.x + column * appSize
                let top = sectionFrame.origin.y + row * appSize;
                
                sectionAttributes.frame = CGRect(x: left, y: top, width: appSize, height: appSize)
            } else {
                sectionAttributes.hidden = true
            }
        }
        
        return sectionAttributes
    }
    
}
