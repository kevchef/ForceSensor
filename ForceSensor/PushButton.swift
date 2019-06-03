//
//  PushButton.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 27.05.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit

@IBDesignable

class PushButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBInspectable var fillColor: UIColor = UIColor.green
    @IBInspectable var scaleFactor: CGFloat = 0.0
    @IBInspectable var posxFactor: CGFloat = 0.0
    @IBInspectable var posyFactor: CGFloat = 0.0

    override func draw(_ rect: CGRect) {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth  = screenSize.width
        let screenHeight = screenSize.height
        
        let centerX = screenWidth / 2
        let centerY = 2*screenHeight / 3
        let size0 = screenWidth / 4
        
        self.frame = CGRect(x: centerX - size0/2*(1+scaleFactor) + size0*posxFactor, y: centerY - size0/2*(1+scaleFactor) + size0*posyFactor, width: size0*(1+scaleFactor), height: size0*(1+scaleFactor))
        
        if scaleFactor >= 0.5 {
            fillColor = UIColor.red
        }
        
        let path = UIBezierPath(ovalIn: rect)
        fillColor.setFill()
        path.fill()
    }

}
