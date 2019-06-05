//
//  ForceAnimationCircle.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 04.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit

class ForceAnimationCircle: UIView {
    
    let screenRect = UIScreen.main.bounds
    let initFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 6.0, height: UIScreen.main.bounds.width / 6.0)
    let generalCenter = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY + 100)
    
    let maxFZ = CGFloat(300)
    let maxFXY = CGFloat(128)
    let duration = 0.16


    private var size: CGFloat
    private var color: UIColor
    private var position: CGPoint
    private var FXY_max: CGFloat
    private var FZ_max: CGFloat
    private var mx = CGFloat(0)
    private var my = CGFloat(0)
    private var circlePath = UIBezierPath()
    private var shapeLayer = CAShapeLayer()

    
    required init?(coder aDecoder: NSCoder) {
        self.size = initFrame.width
        self.color = UIColor.green
//            UIColor(displayP3Red: 0.2, green: 1.0 , blue: 0.2, alpha: 1.0) as! CGColor
        self.position = CGPoint(x: generalCenter.x - size/2, y: generalCenter.y - size/2)
        self.FXY_max = maxFXY
        self.FZ_max = maxFZ
        self.circlePath = UIBezierPath(arcCenter: CGPoint(x: 0,y: 0), radius: self.size, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)

        
        super.init(coder: aDecoder)

        frame = CGRect(x: generalCenter.x, y: generalCenter.y, width: 0, height: 0)
        
        self.shapeLayer.path = self.circlePath.cgPath
        
        self.shapeLayer.fillColor = UIColor.green.cgColor
        self.shapeLayer.strokeColor = UIColor.green.cgColor
        self.shapeLayer.lineWidth = 3.0
        
        let PlusSign = UIBezierPath()
        PlusSign.move(to: CGPoint(x: 0, y: -10))
        PlusSign.addLine(to: CGPoint(x: 0, y: 10))
        PlusSign.move(to: CGPoint(x: -10, y: 0))
        PlusSign.addLine(to: CGPoint(x: 10, y: 0))
        PlusSign.close()


        let plusLayer = CAShapeLayer()
        plusLayer.path = PlusSign.cgPath
        plusLayer.strokeColor = UIColor.black.cgColor
        plusLayer.lineWidth = 3
        self.layer.addSublayer(shapeLayer)
        self.layer.addSublayer(plusLayer)

    }
    
    func AnimateCircle(F_queue: [Force]){
        var currentPoint = generalCenter
        currentPoint.x += CGFloat(F_queue[1].prevX)
        currentPoint.y += CGFloat(F_queue[1].prevY)
        var centerPoint = generalCenter
        centerPoint.x += CGFloat(F_queue[1].X)
        centerPoint.y += CGFloat(F_queue[1].Y)
        var endPoint = generalCenter
        endPoint.x += CGFloat(F_queue[0].prevX)
        endPoint.y += CGFloat(F_queue[0].prevY)
        var nextPoint = generalCenter
        nextPoint.x += CGFloat(F_queue[0].X)
        nextPoint.y += CGFloat(F_queue[0].Y)
        
        
        curvePath(currPoint: currentPoint, centerPoint: centerPoint, endPoint: endPoint, nextPoint: nextPoint)
    }
    
    fileprivate func curvePath( currPoint: CGPoint, centerPoint: CGPoint, endPoint: CGPoint, nextPoint: CGPoint) {
        let path = UIBezierPath()
        let alpha: CGFloat = 1.0/3.0
        
        path.move(to: self.center) // = currPoint
        
        let controlPoint1 = CGPoint(x: currPoint.x - mx * alpha, y: currPoint.y - my * alpha)
        mx = (centerPoint.x - nextPoint.x) / 2.0
        my = (centerPoint.y - nextPoint.y) / 2.0
        let controlPoint2 = CGPoint(x: endPoint.x + mx * alpha, y: endPoint.y + my * alpha)
        
        path.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        // create a new CAKeyframeAnimation that animates the objects position
        let anim = CAKeyframeAnimation(keyPath: "position")
        // set the animations path to our bezier curve
        anim.path = path.cgPath
        // set some more parameters for the animation
        anim.duration = self.duration
        // add the animation to the squares 'layer' property
        self.layer.add(anim, forKey: "animate position along path")
        self.center = endPoint
    }
}
