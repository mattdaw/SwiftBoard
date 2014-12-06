//
//  ItemViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol ItemViewModel: class {
    var dragging: Bool { get set }
    var deleting: Bool { get set }
    var editing: Bool { get set }
    var zoomed: Bool { get set }
    
    var parentListViewModel: ListViewModel? { get set }
    
    func delete()
}