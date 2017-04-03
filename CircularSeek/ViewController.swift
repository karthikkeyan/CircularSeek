//
//  ViewController.swift
//  CircularSeek
//
//  Created by Karthik Keyan on 11/21/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import UIKit

protocol VcDelegate {
    func valueChanged(value: Float)
}

class ViewController: UIViewController,
                      VcDelegate {
    
    let seekBar = CircularSeeker()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        seekBar.frame = CGRect(x: (self.view.frame.size.width - 200) * 0.5, y: (self.view.frame.size.height - 200) * 0.5, width: 200, height: 200)
        seekBar.startAngle = 120
        seekBar.endAngle = 60
        seekBar.currentAngle = 120
        seekBar.thumbColor = UIColor(colorLiteralRed: 242.0/255.0, green: 107.0/255.0, blue: 107.0/255.0, alpha: 1.0)
        seekBar.seekBarColor = UIColor(colorLiteralRed: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1.0)
        seekBar.vcDelegate = self
        self.view.addSubview(seekBar)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        seekBar.frame = CGRect(x: (self.view.frame.size.width - 200) * 0.5, y: (self.view.frame.size.height - 200) * 0.5, width: 200, height: 200)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        seekBar.moveToAngle(angle: 270, duration: 1.0)
    }
    
    func seekBarDidChangeValue(_ sender: AnyObject) {
        print(seekBar.currentAngle)
    }
    
    func valueChanged(value: Float) {
        print("\(value)")
    }

}

