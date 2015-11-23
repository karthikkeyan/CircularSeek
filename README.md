# CircularSeek

```swift
let seekBar = CircularSeeker()
seekBar.frame = CGRect(x: 50, y: 50, width: 200, height: 200)
seekBar.startAngle = 120
seekBar.endAngle = 60
seekBar.currentAngle = 120
seekBar.addTarget(self, action: Selector("seekBarDidChangeValue:"), forControlEvents: .ValueChanged)
self.view.addSubview(seekBar)
```

<img src="https://github.com/karthikkeyan/CircularSeek/blob/master/circularseeker.gif" />


# Logic Behind CircularSeeker

It involves simple trigonometry. The above image is the final output of our control. User can drag the red colored thumb view in the given circular path.


## Formulas

Since UI we are going to develop is a **circle**, code we need to recall our high school trigonometry.

<img src="https://github.com/karthikkeyan/CircularSeek/blob/master/circle-trigonometry.png" />

	sin(θ) = b/c  where b is opposite side, c is hypothenuse 

	cos(θ) = a/c  where a is adjusting side, c is hypothenuse

	tan(θ) = sin(theta)/cos(theta)

	x = cos(angle) * radius + CenterX;

	y = sin(angle) * radius + CenterY;


## Math problems to address

Now, to implement what are all the problems we need to address,

1. We need to find the angle of given point(x, y) in a circle
2. Find here angle intersect, with the circle's border

These two points going to help us move the thumb view.


## Lets Code

Lets create a a new class called **CircularSeeker** subclassing UIControl, so that we can get the benifit of the following three methods.

```swift

func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool

func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool

func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?)

```

### Subview Setup

Lets create a property called **currentAngle** and it's **didSet** will reloayout subviews whenever its value changed.

```swift
var currentAngle: Float = 120.0 {
	didSet {
		self.setNeedsLayout()
	}
}
```

Override the **layoutSubviews** to update circular path and thumb position 

```swift
override func layoutSubviews() {
	super.layoutSubviews()
        
	let center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
        
	let sAngle = degreeToRadian(Double(startAngle))
	let eAngle = degreeToRadian(Double(endAngle))
        
	let path = UIBezierPath(arcCenter: center, radius: (self.bounds.size.width - 18)/2, startAngle: CGFloat(sAngle), endAngle: CGFloat(eAngle), clockwise: true)
	seekerBarLayer.path = path.CGPath
        
	updateThumbPosition()
}
```

Create a function which uses **currentAngle** and calculates the CGRect for the thumb view.

```swift
private func updateThumbPosition() {
	let angle = degreeToRadian(Double(currentAngle))
 
	let x = cos(angle)
	let y = sin(angle)
 
	var rect = thumbButton.frame
 
	let radius = self.frame.size.width * 0.5
	
	let center = CGPointMake(radius, radius)
 
	// x = cos(angle) * radius + CenterX;
	let finalX = (CGFloat(x) * radius) + center.x
 
	// y = sin(angle) * radius + CenterY;
	let finalY = (CGFloat(y) * radius) + center.y
 
	rect.origin.x = finalX
	rect.origin.y = finalY
 
	thumbButton.frame = rect
}
```

### Begin

The size of the thumb 20x20, which is not a good enought size for user interaction. We dont want our user to be touching the views precisely. We want our user to interaction with our views naturally. So we need to increasing the touch region on the thumb view by some points. 

```swift
let rect = CGRectInset(self.thumbButton.frame, -20, -20)
```

the above code returns the increased region of the thumb view by 20 points.

Besides, the touch event methods will get call when/where ever user interact within our view. We dont what that. What we what is to begin the user interaction if only the user touches the **thumb view** of our control. 

```swift

override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
	let point = touch.locationInView(self)
	let rect = CGRectInset(self.thumbButton.frame, -20, -20)
	return CGRectContainsPoint(rect, point)        
}
    
```

so if only user touches anywhere in/around the thumb view, we are beginning the event.


### Move

Now lets write the code to move the thumb. Remember the "Math problems to address".

First, we need to get the angle(θ in circle diagram) of the user's current location. It is simple to calculate using **atan2(y, x)** method.

Here x, is the horizontal distance between users location and center and y is vertical distance.

```swift
let location = touch.locationInView(self)

let dx = location.x - (self.frame.size.width * 0.5)

let dy = location.y - (self.frame.size.height * 0.5)

let angle = Double(atan2(Double(dy), Double(dx)))
```

The problem with the 

Now that we have the angle, we need to find where the angle intersect with circle's border, i.e. the point where the angle meet the circle's border. 

Here is the formula,

	x = cos(angle) * radius + CenterX;

	y = sin(angle) * radius + CenterY;

Putting it all together,

```swift
override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
	let location = touch.locationInView(self)

	let dx = location.x - (self.frame.size.width * 0.5)
	let dy = location.y - (self.frame.size.height * 0.5)
        
	let angle = Double(atan2(Double(dy), Double(dx)))
        
	currentAngle = radianToDegree(angle)
        
	return true
}
```

Now thumb view will rotate in a circular path inside your view's bounds.
