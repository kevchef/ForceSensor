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
    let initFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 3.0, height: UIScreen.main.bounds.width / 3.0)
    let generalCenter = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY + 100)
    
    let maxFZ = CGFloat(300)
    let maxFXY = CGFloat(128)
    let duration = 0.2
    let shapeLayer = CAShapeLayer()


    private var size: CGFloat
    private var color: UIColor
    private var position: CGPoint
    private var FXY_max: CGFloat
    private var FZ_max: CGFloat
    private var mx = CGFloat(0)
    private var my = CGFloat(0)
    
    required init?(coder aDecoder: NSCoder) {
        self.size = initFrame.width
        self.color = UIColor.green
//            UIColor(displayP3Red: 0.2, green: 1.0 , blue: 0.2, alpha: 1.0) as! CGColor
        self.position = CGPoint(x: generalCenter.x - size/2, y: generalCenter.y - size/2)
        self.FXY_max = maxFXY
        self.FZ_max = maxFZ
        super.init(coder: aDecoder)

//        frame = CGRect(x: generalCenter.x - size/2, y: generalCenter.y - self.size/2, width: self.size, height: self.size)
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: UIScreen.main.bounds.midX ,y: UIScreen.main.bounds.midY), radius: CGFloat(50), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 3.0

//        layer.cornerRadius = frame.height/2.0
//        backgroundColor = self.color

    }
    
    func AnimateCircle(F: Force){
        
        var currSize = (CGFloat(F.Z)/FZ_max+1.0) * initFrame.width
        

        var centerPoint = CGPoint(x: generalCenter.x, y: generalCenter.y)
        centerPoint.x += CGFloat(F.prevX)/maxFXY * initFrame.width
        centerPoint.y += CGFloat(F.prevY)/maxFXY * initFrame.width
        var endPoint = CGPoint(x: generalCenter.x, y: generalCenter.y)
        endPoint.x += CGFloat(F.X)/maxFXY * initFrame.width
        endPoint.y += CGFloat(F.Y)/maxFXY * initFrame.width
        
        print("curr \(center)")
        print("frame \(frame)")
        print("centerPoint \(centerPoint)")
        print("endPoint \(endPoint)")
        
        curvePath(centerPoint: centerPoint, endPoint: endPoint)
//        multiPosition(center, endPoint)
        
    }
    
    
    fileprivate func multiPosition(_ firstPos: CGPoint, _ secondPos: CGPoint) {
        func simplePosition(_ pos: CGPoint) {
            UIView.animate(withDuration: self.duration, animations: {
                self.frame.origin = pos
            }, completion: nil)
        }
        
        UIView.animate(withDuration: self.duration, animations: {
            self.frame.origin = firstPos
        }, completion: { finished in
            simplePosition(secondPos)
        })
    }
    
    private func curvePath(centerPoint: CGPoint, endPoint: CGPoint) {
        let path = UIBezierPath()
        let alpha: CGFloat = 1.0/3.0
        
        path.move(to: CGPoint(x: frame.midX, y: frame.midX)) // = currPoint
        
        let controlPoint1 = CGPoint(x: frame.midX - self.mx * alpha, y: frame.midX - self.my * alpha)
        self.mx = (centerPoint.x - endPoint.x)
        self.my = (centerPoint.y - endPoint.y)
        let controlPoint2 = CGPoint(x: endPoint.x + self.mx * alpha, y: endPoint.y + my * alpha)
        
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
