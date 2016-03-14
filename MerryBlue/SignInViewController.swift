//
//  SignInViewController.swift
//  MerryBlue
//
//  Created by Hiroto Takahashi on 2016/03/12.
//  Copyright © 2016年 Hiroto Takahashi. All rights reserved.
//

import Foundation

import UIKit
import TwitterKit

class SignInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logInButton = TWTRLogInButton { (session, error) in
            if session != nil {
                UIApplication.sharedApplication().keyWindow?.rootViewController = MainTabBarController()
                self.presentMainTabBarController()
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
        
        // TODO: Change where the log in button is positioned in your view
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }
    override func viewDidAppear(animated: Bool) {
        guard let _ = Twitter.sharedInstance().sessionStore.session() else {
            return
        }
        self.presentMainTabBarController()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    private func presentMainTabBarController() {
        self.presentViewController(MainTabBarController(), animated: true, completion: nil)
    }
}