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
    var firstView: FirstViewController!
    var secondView: SecondViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstView = FirstViewController()
        secondView = SecondViewController()
        
        firstView.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Featured, tag: 1)
        secondView.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Bookmarks, tag: 2)
        
        let myTabs: Array<UIViewController> = [firstView, secondView]
        
        self.setViewControllers(myTabs, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}