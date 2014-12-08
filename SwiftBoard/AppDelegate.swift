//
//  AppDelegate.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var rootViewModel: RootViewModel?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if let viewController = window?.rootViewController as? ViewController {
            var viewModels: [ItemViewModel] = [
                AppViewModel(name: "App 1", color: UIColor.greenColor()),
                AppViewModel(name: "App 2", color: UIColor.blueColor()),
                FolderViewModel(name: "Folder 1", viewModels: [
                    AppViewModel(name: "App 5", color: UIColor.purpleColor()),
                    AppViewModel(name: "App 6", color: UIColor.redColor()),
                    AppViewModel(name: "App 7", color: UIColor.yellowColor()),
                    AppViewModel(name: "App 8", color: UIColor.magentaColor()),
                    AppViewModel(name: "App 9", color: UIColor.redColor()),
                    AppViewModel(name: "App 10", color: UIColor.purpleColor()),
                    AppViewModel(name: "App 11", color: UIColor.blueColor()),
                    ]),
                FolderViewModel(name: "Folder 2", viewModels: [
                    AppViewModel(name: "App 4", color: UIColor.darkGrayColor())
                    ]),
                AppViewModel(name: "App 3", color: UIColor.cyanColor()),
                AppViewModel(name: "App 12", color: UIColor.magentaColor()),
                AppViewModel(name: "App 13", color: UIColor.orangeColor()),
                AppViewModel(name: "App 14", color: UIColor.brownColor()),
                AppViewModel(name: "App 15", color: UIColor.blueColor()),
                AppViewModel(name: "App 16", color: UIColor.redColor())
            ]
            
            rootViewModel = RootViewModel(viewModels: viewModels)
            viewController.rootViewModel = rootViewModel
        }
        
        return true
    }
    
    // The jiggling animation will be automatically killed if the app loses active status, so I think it's better
    // to treat that as disabling editing mode. Then the view model state and what's happening on screen match.
    func applicationWillResignActive(application: UIApplication) {
        rootViewModel?.editingModeEnabled = false
    }
}

