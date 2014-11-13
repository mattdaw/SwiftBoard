//
//  Folder.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

class Folder: NSObject {
    var name: String
    var apps: NSMutableArray
    
    init(name folderName:String, apps folderApps:NSMutableArray) {
        name = folderName
        apps = folderApps
    }
}