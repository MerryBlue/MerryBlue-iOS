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
        
        if let userName = Twitter.sharedInstance().session()?.userName {
            // ログイン済みは即座にメインページに遷移
            userName
            
            // let vc: UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainTabView") as! UITabBarController
            // self.view.window?.rootViewController!.presentViewController(vc, animated: true, completion: nil)
            
            let tabBarController: UITabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("MainTabView") as! UITabBarController
            UIApplication.sharedApplication().keyWindow?.rootViewController = tabBarController
            return
        }
    }
    
    @IBOutlet var loginButton: UIButton!
    @IBAction func loginAction(sender: AnyObject?) {
        Twitter.sharedInstance().logInWithCompletion {(session, error) in
            if let s = session {
                let alert = UIAlertController(title: "Logged In",
                    message: "User \(s.userName) has logged in",
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
    }
}