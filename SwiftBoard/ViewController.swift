//
//  ViewController.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var rootCollectionView: RootCollectionView!
    private var rootViewModel: RootViewModel?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Move to AppDelegate and pass in
        var viewModels: [ItemViewModel] = [
            AppViewModel(name: "App 1", color: UIColor.greenColor()),
            AppViewModel(name: "App 2", color: UIColor.blueColor()),
            FolderViewModel(name: "Folder 1", viewModels: [
                AppViewModel(name: "App 5", color: UIColor.purpleColor()),
                AppViewModel(name: "App 6", color: UIColor.grayColor()),
                AppViewModel(name: "App 7", color: UIColor.yellowColor()),
                AppViewModel(name: "App 8", color: UIColor.yellowColor()),
                AppViewModel(name: "App 9", color: UIColor.redColor()),
                AppViewModel(name: "App 10", color: UIColor.purpleColor()),
                AppViewModel(name: "App 11", color: UIColor.blueColor()),
                ]),
            FolderViewModel(name: "Folder 2", viewModels: [
                AppViewModel(name: "App 4", color: UIColor.darkGrayColor())
                ]),
            AppViewModel(name: "App 3", color: UIColor.redColor()),
            AppViewModel(name: "App 20", color: UIColor.redColor()),
            AppViewModel(name: "App 21", color: UIColor.redColor()),
            AppViewModel(name: "App 22", color: UIColor.redColor()),
            AppViewModel(name: "App 23", color: UIColor.redColor()),
            AppViewModel(name: "App 24", color: UIColor.redColor())
        ]
        
        rootViewModel = RootViewModel(viewModels: viewModels)
        rootCollectionView.rootViewModel = rootViewModel
    }
    
    @IBAction func handleHomeButton(sender: UIButton) {
        rootViewModel!.editingModeEnabled = false
    }
}














