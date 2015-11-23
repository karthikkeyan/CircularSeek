//
//  CircularSeeker.swift
//  CircularSeek
//
//  Created by Karthik Keyan on 11/21/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import UIKit

func degreeToRadian(degree: Double) -> Double {
    return Double(degree * (M_PI/180))
}

func radianToDegree(radian: Double) -> Double {
    return Double(radian * (180/M_PI))
}


class CircularSeeker: UIControl {
    
    lazy var seekerBarLayer = CAShapeLayer()
    
    lazy var thumbButton = UIButton(type: .Custom)
    
    
    var startAngle: Float = 110.0
    
    var endAngle: Float = 70.0
    
    var currentAngle: Float = 120.0
    
    var seekBarColor: UIColor = UIColor.grayColor()
    
    var thumbColor: UIColor = UIColor.redColor()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSeekerBar()
        addThumb()
        
        moveThumbToAngle(angleInRadians: degreeToRadian(Double(startAngle)))
    }
    
    
    // MARK: Private Methods -
    
    private func addSeekerBar() {
        let center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
        
        let sAngle = degreeToRadian(Double(startAngle))
        let eAngle = degreeToRadian(Double(endAngle))
        
        let path = UIBezierPath(arcCenter: center, radius: (self.bounds.size.width - 18)/2, startAngle: CGFloat(sAngle), endAngle: CGFloat(eAngle), clockwise: true)
        
        seekerBarLayer.path = path.CGPath
        seekerBarLayer.lineWidth = 4.0
        seekerBarLayer.lineCap = kCALineCapRound
        seekerBarLayer.strokeColor = seekBarColor.CGColor
        seekerBarLayer.fillColor = UIColor.clearColor().CGColor
        
        if seekerBarLayer.superlayer == nil {
            self.layer.addSublayer(seekerBarLayer)
        }
    }
    
    private func addThumb() {
        thumbButton.frame = CGRectMake(0, 0, 20, 20)
        thumbButton.backgroundColor = thumbColor
        thumbButton.layer.cornerRadius = thumbButton.frame.size.width/2
        thumbButton.layer.masksToBounds = true
        thumbButton.userInteractionEnabled = false
        
        if thumbButton.superview == nil {
            self.addSubview(thumbButton)
        }
    }
    
    private func moveThumbToAngle(angleInRadians angle: Double) {
        currentAngle = Float(radianToDegree(angle))
        
        let x = cos(angle)
        let y = sin(angle)
        
        var rect = thumbButton.frame
        
        let radius = self.frame.size.width * 0.5
        let thumbCenter: CGFloat = 10.0
        
        let finalX = (CGFloat(x) * (radius - thumbCenter)) + radius
        let finalY = (CGFloat(y) * (radius - thumbCenter)) + radius
        
        rect.origin.x = finalX - thumbCenter
        rect.origin.y = finalY - thumbCenter
        
        thumbButton.frame = rect
    }
    
    private func resetThumb() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: [ .CurveEaseOut, .BeginFromCurrentState ], animations: { () -> Void in
            self.thumbButton.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    
    // MARK: Hit Test -
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let point = touch.locationInView(self)
        
        let rect = CGRectInset(self.thumbButton.frame, -20, -20)
        
        let canBegin = CGRectContainsPoint(rect, point)
        
        if canBegin {
            UIView.animateWithDuration(0.2, delay: 0.0, options: [ .CurveEaseIn, .BeginFromCurrentState ], animations: { () -> Void in
                self.thumbButton.transform = CGAffineTransformMakeScale(1.2, 1.2)
                }, completion: nil)
        }
        
        return canBegin
    }
    
    
    // MARK: Touch Event -
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        let dx = location.x - (self.frame.size.width * 0.5)
        let dy = location.y - (self.frame.size.height * 0.5)
        
        let angle = Double(atan2(Double(dy), Double(dx)))
        
        var degree = radianToDegree(angle)
        if degree < 0 {
            degree = 360 + degree
        }
        
        func moveToClosestEdge(degree: Double) {
            let startDistance = fabs(Float(degree) - startAngle)
            let endDistance = fabs(Float(degree) - endAngle)
            
            if startDistance < endDistance {
                moveThumbToAngle(angleInRadians: degreeToRadian(Double(startAngle)))
            }
            else {
                moveThumbToAngle(angleInRadians: degreeToRadian(Double(endAngle)))
            }
        }
        
        if startAngle > endAngle {
            if degree < Double(startAngle) && degree > Double(endAngle) {
                moveToClosestEdge(degree)
                resetThumb()
                return false
            }
        }
        else {
            if degree > Double(endAngle) || degree < Double(startAngle) {
                moveToClosestEdge(degree)
                resetThumb()
                return false
            }
        }
        
        moveThumbToAngle(angleInRadians: degreeToRadian(degree))
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        resetThumb()
    }
    
    
    
}
