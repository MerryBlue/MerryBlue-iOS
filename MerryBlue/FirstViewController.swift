//
//  FirstViewController.swift
//  MerryBlue
//
//  Created by Hiroto Takahashi on 2016/03/12.
//  Copyright © 2016年 Hiroto Takahashi. All rights reserved.
//

import UIKit
import TwitterKit

class FirstViewController: UIViewController, ModalViewControllerDelegate {
    
    let modalView = AddWatchUserModalViewController()
    let modalTextLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addWatchBtn:UIButton = UIButton(frame: CGRectMake(0, 0, 300, 50))
        addWatchBtn.layer.position = CGPoint(x: self.view.frame.width/2, y: 100)
        addWatchBtn.setTitle("フォロワーから追加", forState: .Normal)
        addWatchBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        addWatchBtn.layer.cornerRadius = 10
        addWatchBtn.layer.borderWidth = 1
        addWatchBtn.addTarget(self, action: "showModal:", forControlEvents:.TouchUpInside)
        self.view.addSubview(addWatchBtn)
        
        self.modalTextLabel.frame = CGRectMake(0, 0, 300, 50)
        self.modalTextLabel.layer.position = CGPoint(x: self.view.frame.width/2, y: 200)
        self.modalTextLabel.textAlignment = .Center
        self.modalTextLabel.text = "The Modal text is ..."
        self.modalTextLabel.textColor = UIColor.blackColor()
        self.view.addSubview(modalTextLabel)
        
        self.modalView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showModal(sender: AnyObject){
        self.presentViewController(self.modalView, animated: true, completion: nil)
    }
    
    func modalDidFinished(modalText: String){
        self.modalTextLabel.text = modalText
        self.modalView.dismissViewControllerAnimated(true, completion: nil)
    }
    


}

