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
    
    
    var startAngle: Float = 110.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var endAngle: Float = 70.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var currentAngle: Float = 120.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var seekBarColor: UIColor = UIColor.grayColor() {
        didSet {
            seekerBarLayer.strokeColor = seekBarColor.CGColor
            self.setNeedsDisplay()
        }
    }
    
    var thumbColor: UIColor = UIColor.redColor() {
        didSet {
            thumbButton.backgroundColor = thumbColor
            self.setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initSubViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: Private Methods -
    
    private func initSubViews() {
        addSeekerBar()
        addThumb()
    }
    
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
        self.addSubview(thumbButton)
    }
    
    private func updateThumbPosition() {
        let angle = degreeToRadian(Double(currentAngle))
        
        let x = cos(angle)
        let y = sin(angle)
        
        var rect = thumbButton.frame
        
        let radius = self.frame.size.width * 0.5
        let center = CGPointMake(radius, radius)
        let thumbCenter: CGFloat = 10.0
        
        // x = cos(angle) * radius + CenterX;
        let finalX = (CGFloat(x) * (radius - thumbCenter)) + center.x
        
        // y = sin(angle) * radius + CenterY;
        let finalY = (CGFloat(y) * (radius - thumbCenter)) + center.y
        
        rect.origin.x = finalX - thumbCenter
        rect.origin.y = finalY - thumbCenter
        
        thumbButton.frame = rect
    }
    
    private func thumbMoveDidComplete() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: [ .CurveEaseOut, .BeginFromCurrentState ], animations: { () -> Void in
            self.thumbButton.transform = CGAffineTransformIdentity
            }, completion: { [weak self] _ in
                self?.fireValueChangeEvent()
            })
    }
    
    private func fireValueChangeEvent() {
        self.sendActionsForControlEvents(.ValueChanged)
    }
    
    private func degreeForLocation(location: CGPoint) -> Double {
        let dx = location.x - (self.frame.size.width * 0.5)
        let dy = location.y - (self.frame.size.height * 0.5)
        
        let angle = Double(atan2(Double(dy), Double(dx)))
        
        var degree = radianToDegree(angle)
        if degree < 0 {
            degree = 360 + degree
        }
        
        return degree
    }
    
    private func moveToPoint(point: CGPoint) -> Bool {
        var degree = degreeForLocation(point)
        
        func moveToClosestEdge(degree: Double) {
            let startDistance = fabs(Float(degree) - startAngle)
            let endDistance = fabs(Float(degree) - endAngle)
            
            if startDistance < endDistance {
                currentAngle = startAngle
            }
            else {
                currentAngle = endAngle
            }
        }
        
        if startAngle > endAngle {
            if degree < Double(startAngle) && degree > Double(endAngle) {
                moveToClosestEdge(degree)
                thumbMoveDidComplete()
                return false
            }
        }
        else {
            if degree > Double(endAngle) || degree < Double(startAngle) {
                moveToClosestEdge(degree)
                thumbMoveDidComplete()
                return false
            }
        }
        
        currentAngle = Float(degree)
        
        return true;
    }
    
    
    // MARK: Public Methods -
    
    func moveToAngle(angle: Float, duration: CFTimeInterval) {
        let center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
        
        let sAngle = degreeToRadian(Double(startAngle))
        let eAngle = degreeToRadian(Double(angle))
        
        let path = UIBezierPath(arcCenter: center, radius: (self.bounds.size.width - 18)/2, startAngle: CGFloat(sAngle), endAngle: CGFloat(eAngle), clockwise: true)
        
        CATransaction.begin()
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.duration = duration
        animation.path = path.CGPath
        thumbButton.layer.addAnimation(animation, forKey: "moveToAngle")
        CATransaction.setCompletionBlock { [weak self] in
            self?.currentAngle = angle
        }
        CATransaction.commit()
    }
    
    
    // MARK: Touch Events -
    
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
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        if #available(iOS 9, *) {
            guard let coalescedTouches = event?.coalescedTouchesForTouch(touch) else {
                return moveToPoint(touch.locationInView(self))
            }
            
            let result = true
            for cTouch in coalescedTouches {
                let result = moveToPoint(cTouch.locationInView(self))
                
                if result == false { break }
            }
            
            return result
        }
        
        return moveToPoint(touch.locationInView(self))
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        thumbMoveDidComplete()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
        
        let sAngle = degreeToRadian(Double(startAngle))
        let eAngle = degreeToRadian(Double(endAngle))
        
        let path = UIBezierPath(arcCenter: center, radius: (self.bounds.size.width - 18)/2, startAngle: CGFloat(sAngle), endAngle: CGFloat(eAngle), clockwise: true)
        seekerBarLayer.path = path.CGPath
        
        updateThumbPosition()
    }
    
}
