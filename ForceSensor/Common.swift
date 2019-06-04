//
//  ForceCircle.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 03.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import Foundation
import UIKit

//let screenRect = UIScreen.main.bounds
//let generalFrame = CGRect(x: 0, y: 0, width: screenRect.width / 2.0, height: screenRect.height / 4.0)
//let generalCenter = CGPoint(x: screenRect.midX, y: screenRect.midY + 100)

func drawCircleView() -> UIView {
    let circlePath = UIBezierPath(arcCenter: CGPoint(x: UIScreen.main.bounds.midX ,y: UIScreen.main.bounds.midY), radius: CGFloat(50), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = circlePath.cgPath
    
    shapeLayer.fillColor = UIColor.red.cgColor
    shapeLayer.strokeColor = UIColor.red.cgColor
    shapeLayer.lineWidth = 3.0
    
    let view = UIView()
    view.layer.addSublayer(shapeLayer)
    
    return view
}
