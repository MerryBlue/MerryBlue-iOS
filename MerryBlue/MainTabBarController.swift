//
//  MainTabBarController.swift
//  MerryBlue
//
//  Created by Hiroto Takahashi on 2016/03/13.
//  Copyright © 2016年 Hiroto Takahashi. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    var watcherView: WatcherViewController!
    var profileView: ProfileViewController!
    
    var watcherNavView: UINavigationController!
    var profileNavView: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        watcherView = WatcherViewController()
        profileView = ProfileViewController()
        
        watcherView.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Featured, tag: 1)
        profileView.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Bookmarks, tag: 2)
        
        watcherNavView = UINavigationController(rootViewController: watcherView)
        profileNavView = UINavigationController(rootViewController: profileView)
        
        let tabs: Array<UINavigationController> = [watcherNavView, profileNavView]
        
        self.setViewControllers(tabs, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}