//
//  CirclularPlot.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 10.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit
import QuartzCore

class CirclularPlot: UIView {
    
    /// The total animation duration of the splash animation
    let kAnimationDuration: TimeInterval = 3.0
    /// The length of the second part of the duration
    let kAnimationDurationDelay: TimeInterval = 0.5
    /// The offset between the AnimatedULogoView and the background Grid
    let kAnimationTimeOffset: CFTimeInterval = 0.35 * TimeInterval(3.0)
    
    fileprivate let strokeEndTimingFunction   = CAMediaTimingFunction(controlPoints: 1.00, 0.0, 0.35, 1.0)
    fileprivate let startTimeOffset = 0.7 * TimeInterval(3.0)

    
    let screenRect = UIScreen.main.bounds
    let generalCenter = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY + 100)
        let duration = 1.0
    
    private var size = CGFloat(200)
    private var color = UIColor.red
    private var position = CGPoint()
    private var maxPath = UIBezierPath()
    private var avgPath = UIBezierPath()
    private var minPath = UIBezierPath()
    
    private var maxLayer = CALayer()
    private var maxShape = CAShapeLayer()
    private var avgLayer = CALayer()
    private var avgShape = CAShapeLayer()
    private var minLayer = CALayer()
    private var minShape = CAShapeLayer()
    
    var maxPoints = [140,170,200,130,70,40,60,80]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }

    func setup(){
        self.size = CGFloat(200)
        self.color = UIColor.green
        
        frame = CGRect(x: generalCenter.x, y: generalCenter.y, width: 0, height: 0)
        
//        self.circlePath = UIBezierPath(arcCenter: CGPoint(x: 0,y: 0), radius: self.size, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        self.maxPath = UIBezierPath()
        var startAngleMax = Double(0.0)
        var endAngleMax = Double.pi/4.0
        var startAngleAvg = Double.pi/80.0
        var endAngleAvg = Double.pi/4.0-Double.pi/80.0
        var startAngleMin = Double.pi/40.0
        var endAngleMin = Double.pi/4.0-Double.pi/40.0


        for i in 0...maxPoints.count-1 {
//            startAngle = startAngle.truncatingRemainder(dividingBy: (2.0*Double.pi))
//            endAngle = startAngle.truncatingRemainder(dividingBy: (2.0*Double.pi))
//            print("start: \(startAngle), end: \(endAngle)")
            
            self.maxPath.addArc(withCenter: CGPoint(x:0,y:0) , radius: CGFloat(maxPoints[i])*1.5, startAngle: CGFloat(startAngleMax) , endAngle: CGFloat(endAngleMax), clockwise: true)
            self.avgPath.addArc(withCenter: CGPoint(x:0,y:0) , radius: CGFloat(maxPoints[i]), startAngle: CGFloat(startAngleAvg) , endAngle: CGFloat(endAngleAvg), clockwise: true)
            self.minPath.addArc(withCenter: CGPoint(x:0,y:0) , radius: CGFloat(maxPoints[i])/1.5, startAngle: CGFloat(startAngleMin) , endAngle: CGFloat(endAngleMin), clockwise: true)
            print("start: \(startAngleAvg), end: \(endAngleAvg)")

//            startAngleMax += Double.pi/5.0
//            endAngleMax += Double.pi/20.0
            startAngleAvg = endAngleAvg
            endAngleAvg += Double.pi/40.0
            startAngleMin = endAngleMin
            endAngleMin += Double.pi/20.0
            
            print("start: \(startAngleAvg), end: \(endAngleAvg)")


//            self.maxPath.addArc(withCenter: CGPoint(x:0,y:0) , radius: CGFloat(1.0), startAngle: CGFloat(startAngleMax) , endAngle: CGFloat(endAngleMax), clockwise: true)
            self.avgPath.addArc(withCenter: CGPoint(x:0,y:0) , radius: CGFloat(10.0), startAngle: CGFloat(startAngleAvg) , endAngle: CGFloat(endAngleAvg), clockwise: true)
            self.minPath.addArc(withCenter: CGPoint(x:0,y:0) , radius: CGFloat(20.0), startAngle: CGFloat(startAngleMin) , endAngle: CGFloat(endAngleMin), clockwise: true)
            
            startAngleMax += Double.pi/4.0
            endAngleMax += Double.pi/4.0
            startAngleAvg = endAngleAvg
            endAngleAvg += Double.pi/4.0 - Double.pi/40.0
            startAngleMin = endAngleMin
            endAngleMin += Double.pi/4.0 - Double.pi/20.0
        }
        
        self.maxPath.close()
//        self.circlePath.move(to: CGPoint(x: generalCenter.x, y: generalcenter.y - maxPoints[1]))
        
//        // add circle as shapelayer - sublayer of main layer
        self.maxShape.path = self.maxPath.cgPath
        self.maxShape.fillColor = UIColor.blue.cgColor
////        self.maxLayer.strokeColor = UIColor.blue.cgColor
////        self.maxLayer.lineWidth = 20.0
        self.layer.addSublayer(maxLayer)
        self.maxLayer.addSublayer(maxShape)
        
        addAnimation(delay: 0.5, Layer: maxLayer)
        
        self.avgShape.path = self.avgPath.cgPath
        self.avgShape.fillColor = UIColor.red.cgColor
//        self.avgLayer.strokeColor = UIColor.red.cgColor
//        self.avgLayer.lineWidth = 10.0
        self.layer.addSublayer(avgLayer)
        self.avgLayer.addSublayer(avgShape)
        
        addAnimation(delay: 1.0, Layer: avgLayer)

        self.minShape.path = self.minPath.cgPath
        self.minShape.fillColor = UIColor.black.cgColor
        self.layer.addSublayer(minLayer)
        self.minLayer.addSublayer(minShape)

        addAnimation(delay: 1.5, Layer: minLayer)
        


    }
    
    func addAnimation(delay: Double, Layer: CALayer){
        let radius = CGFloat(400)
        let maskLayer = CAShapeLayer()
        
        Layer.mask = maskLayer

        maskLayer.lineWidth = radius
        maskLayer.path = UIBezierPath(arcCenter: CGPoint.zero, radius: radius/2.0+5, startAngle: CGFloat(0.0), endAngle: CGFloat(2.0*Double.pi), clockwise: true).cgPath
        maskLayer.strokeColor = UIColor.clear.cgColor
        maskLayer.fillColor = UIColor.clear.cgColor
        
        let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
        colorAnimation.fromValue = UIColor.clear.cgColor
        colorAnimation.toValue = UIColor.white.cgColor
//        colorAnimation.beginTime = CACurrentMediaTime() + delay
        colorAnimation.duration = 0.1
        colorAnimation.isRemovedOnCompletion = false
        colorAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0
        strokeAnimation.toValue = 1
//        strokeAnimation.beginTime = colorAnimation.beginTime + colorAnimation.duration
        strokeAnimation.duration = 2.0
//        strokeAnimation.beginTime = CACurrentMediaTime() + delay
        strokeAnimation.fillMode = CAMediaTimingFillMode.forwards
        strokeAnimation.isRemovedOnCompletion = false
//        maskLayer.add(strokeAnimation, forKey: "line")
        
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        var startingTransform = CATransform3DMakeRotation(-CGFloat(Double.pi), 0, 0, 1)
        startingTransform = CATransform3DScale(startingTransform, 1, 1, 1)
        transformAnimation.fromValue = NSValue(caTransform3D:startingTransform)
        transformAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1, 1, 1.0))
//        transformAnimation.beginTime = colorAnimation.beginTime + colorAnimation.duration
        transformAnimation.duration = 2.0
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [colorAnimation, strokeAnimation, transformAnimation]
        groupAnimation.duration = 5.0
        groupAnimation.beginTime = CACurrentMediaTime() + delay
        groupAnimation.fillMode = CAMediaTimingFillMode.forwards
        groupAnimation.isRemovedOnCompletion = false
        
        maskLayer.add(groupAnimation,forKey: nil)
        
        
    }
    
}
