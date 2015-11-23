//
//  ViewController.swift
//  CircularSeek
//
//  Created by Karthik Keyan on 11/21/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let seekBar = CircularSeeker()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        seekBar.frame = CGRect(x: (self.view.frame.size.width - 200) * 0.5, y: (self.view.frame.size.height - 200) * 0.5, width: 200, height: 200)
        seekBar.startAngle = 120
        seekBar.endAngle = 60
        seekBar.currentAngle = 120
        seekBar.addTarget(self, action: Selector("seekBarDidChangeValue:"), forControlEvents: .ValueChanged)
        self.view.addSubview(seekBar)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        seekBar.frame = CGRect(x: (self.view.frame.size.width - 200) * 0.5, y: (self.view.frame.size.height - 200) * 0.5, width: 200, height: 200)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func seekBarDidChangeValue(sender: AnyObject) {
        print(seekBar.currentAngle)
    }

}

