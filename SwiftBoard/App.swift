//
//  App.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class App: NSObject {
    var name: String
    var color: UIColor
    
    init(name appName:String, color appColor:UIColor) {
        name = appName
        color = appColor
    }
}