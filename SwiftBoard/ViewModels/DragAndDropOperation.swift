//
//  DragAndDropOperation.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-21.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

@objc protocol DragOperation {
    func dragStart()
    
}

@objc protocol DragAndDropOperation: DragOperation {
    func dragCancel()
    func drop()
}
