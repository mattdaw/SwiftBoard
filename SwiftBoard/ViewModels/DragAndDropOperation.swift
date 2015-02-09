//
//  DragAndDropOperation.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-21.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol DragOperation {
    func dragStart()
    
}

protocol DragAndDropOperation: DragOperation {
    func dragCancel()
    func drop()
}
