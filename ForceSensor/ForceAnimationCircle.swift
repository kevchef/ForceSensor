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
    
    let maxFZ = CGFloat(-100)
    let maxFXY = CGFloat(128)
    let duration = 1.0


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
        
        // add circle as shapelayer - sublayer of main layer
        self.shapeLayer.path = self.circlePath.cgPath
        self.shapeLayer.fillColor = UIColor.green.cgColor
        self.shapeLayer.strokeColor = UIColor.green.cgColor
        self.shapeLayer.lineWidth = 3.0
        self.layer.addSublayer(shapeLayer)

        //add plusSign in the center of the Circle as sublayer of shapeLayer
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
        self.shapeLayer.addSublayer(plusLayer)
        
        //add plusSign in the center as sublayer of main layer
        let PlusSignCenter = UIBezierPath()
        PlusSignCenter.move(to: CGPoint(x: 0, y: -10))
        PlusSignCenter.addLine(to: CGPoint(x: 0, y: 10))
        PlusSignCenter.move(to: CGPoint(x: -10, y: 0))
        PlusSignCenter.addLine(to: CGPoint(x: 10, y: 0))
        PlusSignCenter.close()
        let plusLayerCenter = CAShapeLayer()
        plusLayerCenter.path = PlusSign.cgPath
        plusLayerCenter.strokeColor = UIColor.black.cgColor
        plusLayerCenter.lineWidth = 3
        self.layer.addSublayer(plusLayerCenter)
        
        let DashedMaxCircle = UIBezierPath(arcCenter: CGPoint(x: 0,y: 0), radius: 2*self.initFrame.width, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        let DashedMaxCircleLayer = CAShapeLayer()
        DashedMaxCircleLayer.path = DashedMaxCircle.cgPath
        DashedMaxCircleLayer.strokeColor = UIColor.black.cgColor
        DashedMaxCircleLayer.fillColor = UIColor.clear.cgColor
        DashedMaxCircleLayer.lineWidth = 3
        let DashPattern: [NSNumber]?  = [10,3]
        DashedMaxCircleLayer.lineDashPattern = DashPattern
        self.shapeLayer.addSublayer(DashedMaxCircleLayer)
        
        
    }
    
    func AnimateCircle(F_queue: [Force]){
        var currentPoint = CGPoint(x:0, y:0)
        currentPoint.x += CGFloat(F_queue[1].prevX)
        currentPoint.y += CGFloat(-F_queue[1].prevY)
        var centerPoint = CGPoint(x:0, y:0)
        centerPoint.x += CGFloat(F_queue[1].X)
        centerPoint.y += CGFloat(-F_queue[1].Y)
        var endPoint = CGPoint(x:0, y:0)
        endPoint.x += CGFloat(F_queue[0].prevX)
        endPoint.y += CGFloat(-F_queue[0].prevY)
        var nextPoint = CGPoint(x:0, y:0)
        nextPoint.x += CGFloat(F_queue[0].X)
        nextPoint.y += CGFloat(-F_queue[0].Y)
        
//        curvePath(currPoint: currentPoint, centerPoint: centerPoint, endPoint: endPoint, nextPoint: nextPoint)
        moveCircle(endPoint: nextPoint)
        
        let currScale = CGFloat(F_queue[0].Z)/maxFZ
        changeCircleColor(currScale: currScale)
        let currSize = (CGFloat(F_queue[0].Z)/maxFZ + 1) * initFrame.width
        changeCircleSize(currSize: currSize)
    }
    
    fileprivate func changeCircleSize(currSize: CGFloat){
        self.circlePath = UIBezierPath(arcCenter: CGPoint(x: 0,y: 0), radius: currSize, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        self.shapeLayer.path = circlePath.cgPath
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = self.duration
        animation.toValue = circlePath.cgPath
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        
        self.shapeLayer.add(animation, forKey:"")
        
        self.size = currSize;
    }
    
    fileprivate func changeCircleColor(currScale: CGFloat){
        var currColor = UIColor.green
        if (currScale > 1){
            currColor = UIColor.red
        } else if(currScale > 0){
            currColor = UIColor(displayP3Red: currScale, green: 1.0-currScale, blue: 0.3, alpha: 1.0)}
        
        let animation = CABasicAnimation(keyPath: "fillColor")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = self.duration
        animation.toValue = currColor.cgColor
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        self.shapeLayer.add(animation, forKey:"")
        
        let animation1 = CABasicAnimation(keyPath: "strokeColor")
        animation1.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation1.duration = self.duration
        animation1.toValue = currColor.cgColor
        animation1.fillMode = CAMediaTimingFillMode.forwards
        animation1.isRemovedOnCompletion = false
        self.shapeLayer.add(animation1, forKey:"")


//        self.shapeLayer.fillColor = currColor.cgColor;
//        self.shapeLayer.strokeColor = currColor.cgColor
        self.color = currColor
    }
    
    fileprivate func curvePath( currPoint: CGPoint, centerPoint: CGPoint, endPoint: CGPoint, nextPoint: CGPoint) {
        let path = UIBezierPath()
        let alpha: CGFloat = 1.0/3.0
        
        path.move(to: self.shapeLayer.position) // = currPoint
        
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
        anim.isRemovedOnCompletion = false
        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        // add the animation to the squares 'layer' property
        self.shapeLayer.add(anim, forKey: "animate position along path")
        self.shapeLayer.position = endPoint
    }
    
    func moveCircle(endPoint: CGPoint){
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = self.duration
        animation.toValue = endPoint
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        
        self.shapeLayer.add(animation, forKey:"")
    }
}
