//
//  ProgressBar.swift
//  ForceSensorTests
//
//  Created by Kevin Schneider on 15.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit

class ProgressBar: UIView {
    
    // MainLayer where everything gets stored on
    private var progressShapeLayer = CAShapeLayer()
    let widthBorder = CGFloat(20)
    let moveInwards = CGFloat(2)
    
    
    private var frameSize = CGSize()
    private var zeroPos = CGFloat()
    private var maxPos = CGFloat()
    private var progressBarRadius = CGFloat()
    private var currRect = CGRect()
    private var zeroSize = CGSize()
    
    private var currProgress: CGFloat = 0.0

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup(){
        frameSize = frame.size
        zeroPos = 3*frameSize.height/4.0
        maxPos = 1*frameSize.height/10.0
        progressBarRadius = (frameSize.width-2*widthBorder-2*moveInwards)/2
        
        // createFrame
        let frameLayer = CAShapeLayer()
        frameLayer.path = UIBezierPath(roundedRect: CGRect(x: widthBorder, y: 0.0, width: frameSize.width - 2*widthBorder, height: frameSize.height), cornerRadius: (frame.size.width-2*widthBorder)/2).cgPath
        frameLayer.fillColor = UIColor.white.cgColor
        frameLayer.strokeColor = UIColor.black.cgColor
        frameLayer.lineWidth = 2
        layer.addSublayer(frameLayer)
        
        
        // create initial ProgressBar
        layer.addSublayer(self.progressShapeLayer)
        let startPoint = CGPoint(x: widthBorder + moveInwards, y: self.zeroPos)
        self.zeroSize = CGSize(width: 2*self.progressBarRadius, height: self.frameSize.height - self.zeroPos - moveInwards)
        self.currRect = CGRect(origin: startPoint, size: zeroSize)
        
        progressShapeLayer.frame = self.currRect
        progressShapeLayer.cornerRadius = self.progressBarRadius
        progressShapeLayer.backgroundColor = UIColor(named: "CircularPlot2")?.cgColor
        
        // addLines
        let lineLayer = CALayer()
        let lines = computeProgressLineSegments(atPercents: [0,0.25,0.5,0.75,1.0])
        
        for line in lines{
            lineLayer.addLineLayer(lineSegment: line, color: UIColor.black.cgColor, width: 1, isDashed: true, animated: false)
        }
        layer.addSublayer(lineLayer)
        
    }
    
    // setup for animating the progress Bar, change accepts values between -1 and 1
    func update(good: Bool){
        
        let perform = good ? 1 : 0
        let maxHeight = self.frameSize.height - self.maxPos //- moveInwards
        let goodScaling = min((maxHeight-self.currRect.height)/(maxHeight),0.5)
        let badScaling = min((self.currRect.height)/(maxHeight),0.5)
        
        // parameter to regulate the increase of the bar
        let maxIncrease = (maxHeight-self.zeroSize.height)/10.0
        
        var currHeight = self.currRect.height + (goodScaling * CGFloat(perform) + badScaling * CGFloat(perform-1)) * maxIncrease
        
        if( currHeight >= maxHeight){ currHeight = maxHeight}
        else if( currHeight <= 0 ){ currHeight = 0}
        
        let startPoint = CGPoint(x: widthBorder + moveInwards, y: self.frameSize.height - currHeight - moveInwards)
        let sizeRect = CGSize(width: 2*self.progressBarRadius, height: currHeight)
        self.currRect = CGRect(origin: startPoint, size: sizeRect)
        
        animateBar()
        
        self.progressShapeLayer.frame = currRect

        }
    
    // actual animation function which gets called from setup()
    func animateBar(){
        
        let animBounds = CABasicAnimation(keyPath: "bounds")
//        animBounds.fromValue = self.currRect
        animBounds.toValue = self.currRect
        animBounds.duration = 2.0
        animBounds.isRemovedOnCompletion = false
        animBounds.fillMode = CAMediaTimingFillMode.forwards
        animBounds.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.progressShapeLayer.add(animBounds, forKey: "bounds")
        
        let animPosition = CABasicAnimation(keyPath: "position")
//        animPosition.fromValue = CGPoint(x: self.currRect.midX, y: self.currRect.midY)
        animPosition.toValue = CGPoint(x: currRect.midX, y: currRect.midY)
        animPosition.duration = 2.0
        animPosition.isRemovedOnCompletion = false
        animPosition.fillMode = CAMediaTimingFillMode.forwards
        animPosition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.progressShapeLayer.add(animPosition, forKey: "position")
    }
    
    
    func computeProgressLineSegments(atPercents: [CGFloat]) -> [LineSegment]{
        var Lines: [LineSegment] = []
        let overShoot = CGFloat(10)
        
        for percent in atPercents{
            let startPoint = CGPoint(x: widthBorder - overShoot, y: self.zeroPos + percent*(self.maxPos-self.zeroPos) )
            let endPoint = CGPoint(x: self.frameSize.width - widthBorder + overShoot, y: self.zeroPos + percent*(self.maxPos-self.zeroPos) )

            let line = LineSegment(startPoint: startPoint, endPoint: endPoint)
            Lines.append(line)
        }
        return Lines
    }
}
