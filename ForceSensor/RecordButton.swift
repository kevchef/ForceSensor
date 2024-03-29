//
//  RecordButton.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 05.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit

@IBDesignable
class RecordButton: UIButton {

    var pathLayer:CAShapeLayer!
    let animationDuration = 0.4
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    //common set up code
    func setup()
    {
        // add white background with black stroke for button
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = UIBezierPath(roundedRect: CGRect(x:3, y:3, width:60, height:60), cornerRadius: 30).cgPath
        backgroundLayer.fillColor = UIColor.white.cgColor
        backgroundLayer.strokeColor = UIColor.black.cgColor
        backgroundLayer.lineWidth = 6
        self.layer.addSublayer(backgroundLayer)
        
        //add a shape layer for the inner shape to be able to animate it
        frame = CGRect(x: UIScreen.main.bounds.midX-33, y: UIScreen.main.bounds.maxY-80, width: 66, height: 66)
        self.pathLayer = CAShapeLayer()
        
        //show the right shape for the current state of the control
        self.pathLayer.path = self.currentInnerPath().cgPath
        
        //don't use a stroke color, which would give a ring around the inner circle
        self.pathLayer.strokeColor = nil
        
        //set the color for the inner shape
        self.pathLayer.fillColor = UIColor.red.cgColor
        
        //add the path layer to the control layer so it gets drawn
        self.layer.addSublayer(self.pathLayer)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        //lock the size to match the size of the camera button
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute:.width,
                                              relatedBy:.equal,
                                              toItem:nil,
                                              attribute:.width,
                                              multiplier:1,
                                              constant:66.0))
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute:.height,
                                              relatedBy:.equal,
                                              toItem:nil,
                                              attribute:.width,
                                              multiplier:1,
                                              constant:66.0))
        
        //clear the title
        self.setTitle("", for:UIControl.State.normal)
        
        //add out target for event handling
        self.addTarget(self, action: #selector(touchUpInside), for: UIControl.Event.touchUpInside)
        self.addTarget(self, action: #selector(touchDown), for: UIControl.Event.touchDown)
    }
    
    
    override func prepareForInterfaceBuilder()
    {
        //clear the title
        self.setTitle("", for:UIControl.State.normal)
    }
    
    override var isSelected:Bool{
        didSet{
            //change the inner shape to match the state
            let morph = CABasicAnimation(keyPath: "path")
            morph.duration = animationDuration;
            morph.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            
            //change the shape according to the current state of the control
            morph.toValue = self.currentInnerPath().cgPath
            
            //ensure the animation is not reverted once completed
            morph.fillMode = CAMediaTimingFillMode.forwards
            morph.isRemovedOnCompletion = false
            
            //add the animation
            self.pathLayer.add(morph, forKey:"")
        }
    }
    
    @objc func touchUpInside(sender:UIButton)
    {
        //Create the animation to restore the color of the button
        let colorChange = CABasicAnimation(keyPath: "fillColor")
        colorChange.duration = animationDuration;
        colorChange.toValue = UIColor.red.cgColor
        
        //make sure that the color animation is not reverted once the animation is completed
        colorChange.fillMode = CAMediaTimingFillMode.forwards
        colorChange.isRemovedOnCompletion = false
        
        //indicate which animation timing function to use, in this case ease in and ease out
        colorChange.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        //add the animation
        self.pathLayer.add(colorChange, forKey:"darkColor")
        
        //change the state of the control to update the shape
        self.isSelected = !self.isSelected
    }
    
    func switchState()
    {
        //Create the animation to restore the color of the button
        let colorChange = CABasicAnimation(keyPath: "fillColor")
        colorChange.duration = animationDuration;
        colorChange.toValue = UIColor.red.cgColor
        
        //make sure that the color animation is not reverted once the animation is completed
        colorChange.fillMode = CAMediaTimingFillMode.forwards
        colorChange.isRemovedOnCompletion = false
        
        //indicate which animation timing function to use, in this case ease in and ease out
        colorChange.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        //add the animation
        self.pathLayer.add(colorChange, forKey:"darkColor")
        
        //change the state of the control to update the shape
        self.isSelected = !self.isSelected
    }

    
    @objc func touchDown(sender:UIButton)
    {
        //when the user touches the button, the inner shape should change transparency
        //create the animation for the fill color
        let morph = CABasicAnimation(keyPath: "fillColor")
        morph.duration = animationDuration;
        
        //set the value we want to animate to
        morph.toValue = UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 0.5).cgColor
        
        //ensure the animation does not get reverted once completed
        morph.fillMode = CAMediaTimingFillMode.forwards
        morph.isRemovedOnCompletion = false
        
        morph.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.pathLayer.add(morph, forKey:"")
    }
    
//    override func draw(_ rect: CGRect) {
//        //always draw the outer ring, the inner control is drawn during the animations
//        let outerRing = UIBezierPath(ovalIn: CGRect(x:3, y:3, width:60, height:60))
//        outerRing.lineWidth = 6
//        UIColor.black.setStroke()
//        outerRing.stroke()
//    }
    
    func currentInnerPath () -> UIBezierPath
    {
        //choose the correct inner path based on the control state
        var returnPath:UIBezierPath;
        if (self.isSelected)
        {
            returnPath = self.innerSquarePath()
            print("record data")
        }
        else
        {
            returnPath = self.innerCirclePath()
            print("stop recording")
        }
        
        return returnPath
    }
    
    func innerCirclePath () -> UIBezierPath
    {
        return UIBezierPath(roundedRect: CGRect(x:8, y:8, width:50, height:50), cornerRadius: 25)
    }
    
    func innerSquarePath () -> UIBezierPath
    {
        return UIBezierPath(roundedRect: CGRect(x:18, y:18, width:30, height:30), cornerRadius: 4)
    }
}
