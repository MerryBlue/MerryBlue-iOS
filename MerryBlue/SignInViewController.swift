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
            if let unwrappedSession = session {
                let alert = UIAlertController(title: "Logged In",
                    message: "User \(unwrappedSession.userName) has logged in",
                    preferredStyle: UIAlertControllerStyle.Alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                let tabBarController: UITabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("MainTabView") as! UITabBarController
                UIApplication.sharedApplication().keyWindow?.rootViewController = tabBarController
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
        
        // TODO: Change where the log in button is positioned in your view
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }
}