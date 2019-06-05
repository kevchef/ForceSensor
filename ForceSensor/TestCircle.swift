//
//  TestCircle.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 05.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit

class TestCircle: UIView {
    
    var CircleLayer = CAShapeLayer();

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        frame = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY-200, width: 0, height: 0)
        let CirclePath = UIBezierPath(arcCenter: CGPoint(x:0, y:0), radius: CGFloat(50), startAngle: CGFloat(0), endAngle: CGFloat(2*Double.pi), clockwise: true)
        
        CircleLayer.path = CirclePath.cgPath
        CircleLayer.fillColor = UIColor.blue.cgColor
        self.layer.addSublayer(CircleLayer)
    }
    
    func animate(){
        let animation = CABasicAnimation(keyPath: "path")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = 5.0
        let ChangePath = UIBezierPath(arcCenter: CGPoint(x:0, y:0), radius: CGFloat(200), startAngle: CGFloat(0), endAngle: CGFloat(2*Double.pi), clockwise: true)

        animation.toValue = ChangePath.cgPath
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        
        self.CircleLayer.add(animation, forKey:"")

    }
}
