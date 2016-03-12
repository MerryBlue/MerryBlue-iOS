//
//  SecondViewController.swift
//  MerryBlue
//
//  Created by Hiroto Takahashi on 2016/03/12.
//  Copyright © 2016年 Hiroto Takahashi. All rights reserved.
//

import UIKit
import TwitterKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet var logoutButton: UIButton!
    @IBAction func logoutAction(sender: AnyObject?) {
        let store = Twitter.sharedInstance().sessionStore
        if let userID = store.session()!.userID {
            store.logOutUserID(userID)
        }
    }


}

