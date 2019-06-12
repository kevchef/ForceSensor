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
    
    let screenRect = UIScreen.main.bounds
    let duration = 1.0
    
    private var relativeCenter = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY + 100)
    
    private var size: CGFloat = 100
    private var maxRadius = [CGFloat]()
    private var avgRadius = [CGFloat]()
    private var minRadius = [CGFloat]()

    private var maxPath = UIBezierPath()
    private var avgPath = UIBezierPath()
    private var minPath = UIBezierPath()
    
    private var maxLayer = CALayer()
    private var maxShape = CAShapeLayer()
    private var avgLayer = CALayer()
    private var avgShape = CAShapeLayer()
    private var minLayer = CALayer()
    private var minShape = CAShapeLayer()
    
    var maxPoints : [CGFloat] = [140,170,200,130,70,40,60,80]
    var avgPoints : [CGFloat] = [120,140,180,110,60,35,55,60]
    var minPoints : [CGFloat] = [100,110,150,105,55,30,53,55]

    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
//        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        self.setup()
    }

    func setup(minP: [CGFloat]?, avgP: [CGFloat]?, maxP: [CGFloat]?){
        self.relativeCenter = CGPoint(x: frame.width/2, y: frame.height/2)
        self.size = min(frame.width,frame.height)/2
        
        self.minPoints = minP ?? self.minPoints
        self.avgPoints = avgP ?? self.avgPoints
        self.maxPoints = maxP ?? self.maxPoints
        
        let maxP = self.size/CGFloat(self.maxPoints.max()!)
        self.maxRadius = maxPoints.map{$0 * maxP}
        self.avgRadius = avgPoints.map{$0 * maxP}
        self.minRadius = minPoints.map{$0 * maxP}

        self.maxPath = UIBezierPath()
        var startAngleMax = Double(0.0)
        var endAngleMax = Double.pi/4.0
        var startAngleAvg = Double.pi/80.0
        var endAngleAvg = Double.pi/4.0-Double.pi/80.0
        var startAngleMin = Double.pi/40.0
        var endAngleMin = Double.pi/4.0-Double.pi/40.0


        for i in 0...maxPoints.count-1 {
            self.maxPath.addArc(withCenter: self.relativeCenter, radius: self.maxRadius[i], startAngle: CGFloat(startAngleMax) , endAngle: CGFloat(endAngleMax), clockwise: true)
            self.avgPath.addArc(withCenter: self.relativeCenter, radius: self.avgRadius[i], startAngle: CGFloat(startAngleAvg) , endAngle: CGFloat(endAngleAvg), clockwise: true)
            self.minPath.addArc(withCenter: self.relativeCenter, radius: self.minRadius[i], startAngle: CGFloat(startAngleMin) , endAngle: CGFloat(endAngleMin), clockwise: true)
//            print("start: \(startAngleAvg), end: \(endAngleAvg)")

            startAngleAvg = endAngleAvg
            endAngleAvg += Double.pi/40.0
            startAngleMin = endAngleMin
            endAngleMin += Double.pi/20.0
            
//            self.maxPath.addArc(withCenter: CGPoint(x:0,y:0) , radius: CGFloat(1.0), startAngle: CGFloat(startAngleMax) , endAngle: CGFloat(endAngleMax), clockwise: true)
            self.avgPath.addArc(withCenter: self.relativeCenter, radius: self.avgRadius.min()!/2, startAngle: CGFloat(startAngleAvg) , endAngle: CGFloat(endAngleAvg), clockwise: true)
            self.minPath.addArc(withCenter: self.relativeCenter, radius: self.minRadius.min()!/2, startAngle: CGFloat(startAngleMin) , endAngle: CGFloat(endAngleMin), clockwise: true)
            
            startAngleMax += Double.pi/4.0
            endAngleMax += Double.pi/4.0
            startAngleAvg = endAngleAvg
            endAngleAvg += Double.pi/4.0 - Double.pi/40.0
            startAngleMin = endAngleMin
            endAngleMin += Double.pi/4.0 - Double.pi/20.0
        }
        
        self.maxPath.close()
        self.avgPath.close()
        self.minPath.close()
        
//        // add circle as shapelayer - sublayer of main layer
        self.maxShape.path = self.maxPath.cgPath
        self.maxShape.fillColor = UIColor(named: "CircularPlot1")?.cgColor
//        self.maxLayer.strokeColor = UIColor.blue.cgColor
//        self.maxLayer.lineWidth = 20.0
        self.layer.addSublayer(maxLayer)
        self.maxLayer.addSublayer(maxShape)
        
        addAnimation(delay: 0.5, Layer: self.maxLayer)
        
        self.avgShape.path = self.avgPath.cgPath
        self.avgShape.fillColor = UIColor(named: "CircularPlot2")?.cgColor
//        self.avgLayer.strokeColor = UIColor.red.cgColor
//        self.avgLayer.lineWidth = 10.0
        self.layer.addSublayer(avgLayer)
        self.avgLayer.addSublayer(avgShape)
        
        addAnimation(delay: 1.0, Layer: avgLayer)
        
        self.minShape.path = self.minPath.cgPath
        self.minShape.fillColor = UIColor(named: "CircularPlot3")?.cgColor
        self.layer.addSublayer(minLayer)
        self.minLayer.addSublayer(minShape)

        addAnimation(delay: 1.5, Layer: minLayer)


    }
    
    func addAnimation(delay: Double, Layer: CALayer){
        let radius = min(frame.width,frame.height)
        let maskLayer = CAShapeLayer()
        
        Layer.mask = maskLayer
        
        maskLayer.lineWidth = radius
        maskLayer.path = UIBezierPath(arcCenter: self.relativeCenter, radius: radius/2.0, startAngle: CGFloat(0.0), endAngle: CGFloat(2.0*Double.pi), clockwise: true).cgPath
        maskLayer.strokeColor = UIColor.clear.cgColor
        maskLayer.fillColor = UIColor.clear.cgColor
        
        let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
        colorAnimation.fromValue = UIColor.clear.cgColor
        colorAnimation.toValue = UIColor.white.cgColor
        colorAnimation.duration = 0.1
        colorAnimation.isRemovedOnCompletion = false
        colorAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0
        strokeAnimation.toValue = 1
        strokeAnimation.duration = 0.8
        strokeAnimation.fillMode = CAMediaTimingFillMode.forwards
        strokeAnimation.isRemovedOnCompletion = false
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [colorAnimation, strokeAnimation] //transformAnimation]
        groupAnimation.duration = 5.0
        groupAnimation.beginTime = CACurrentMediaTime() + delay
        groupAnimation.fillMode = CAMediaTimingFillMode.forwards
        groupAnimation.isRemovedOnCompletion = false
        
        maskLayer.add(groupAnimation,forKey: nil)
    }
    
}
