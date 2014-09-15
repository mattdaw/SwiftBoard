//
//  Folder.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

class Folder {
    var name: String
    var apps: [App]
    
    init(name myName:String, apps myApps:[App]) {
        name = myName
        apps = myApps
    }
}