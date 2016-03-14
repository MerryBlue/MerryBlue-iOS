import Foundation
import UIKit

protocol ListChooseModalViewControllerDelegate {
    func modalDidFinished(modalText: String)
}

class ListChooseModalViewController: UIViewController {
    
    var delegate: ListChooseModalViewControllerDelegate! = nil
    let text1 = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.orangeColor()
        
        self.text1.frame = CGRectMake(0, 0, 300, 50)
        self.text1.layer.position = CGPoint(x: self.view.frame.width/2, y:100)
        self.text1.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.text1)
        
        let submitBtn = UIButton(frame: CGRectMake(0, 0, 300, 50))
        submitBtn.layer.position = CGPoint(x: self.view.frame.width/2, y:200)
        submitBtn.setTitle("Submit", forState: .Normal)
        submitBtn.addTarget(self, action: "submit:", forControlEvents: .TouchUpInside)
        self.view.addSubview(submitBtn)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func submit(sender: AnyObject) {
        self.delegate.modalDidFinished(self.text1.text!)
    }
}