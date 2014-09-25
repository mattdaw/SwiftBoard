//
//  SwiftBoardCell.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-25.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

@objc protocol SwiftBoardCell {
    func pointInsideIcon(point:CGPoint) -> Bool
}