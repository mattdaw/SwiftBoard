//
//  AppViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

protocol AppViewModelDelegate: class {
    func appViewModelDraggingDidChange(dragging: Bool)
}

class AppViewModel: SwiftBoardViewModel {
    var name: String
    var color: UIColor
    
    var dragging: Bool = false {
        didSet {
            delegate?.appViewModelDraggingDidChange(dragging)
        }
    }
    
    weak var delegate: AppViewModelDelegate?
    
    init(name appName:String, color appColor:UIColor) {
        name = appName
        color = appColor
    }
}
