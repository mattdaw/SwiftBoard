//
//  CollectionViewLayoutAttributes.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-10-01.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class CollectionViewLayoutAttributes : UICollectionViewLayoutAttributes {
    
    var editingModeEnabled = false
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        var attributes:CollectionViewLayoutAttributes = super.copyWithZone(zone) as CollectionViewLayoutAttributes
        attributes.editingModeEnabled = editingModeEnabled
        
        return attributes
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if self === object {
            return true
        } else if let castObject = object as? CollectionViewLayoutAttributes {
            if editingModeEnabled == castObject.editingModeEnabled {
                return super.isEqual(object)
            }
        }
        
        return false
    }
    
}
