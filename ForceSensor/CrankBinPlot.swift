//
//  CrankBinPlot.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 13.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit

class CrankBinPlot: UIView {

    let screenRect = UIScreen.main.bounds
    let duration = 1.0
    
    private var relativeCenter = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY + 100)
    
    private var MinMaxR: CGFloat = 100
    private var minR: CGFloat = 10
    private var maxR: CGFloat = 200
    private var zeroR: CGFloat = 45
    
    private var maxRadius = [CGFloat]()
    private var avgRadius = [CGFloat]()
    private var stdRadius = [CGFloat]()
    private var minRadius = [CGFloat]()
    
    private var maxPath = UIBezierPath()
    private var avgPath = UIBezierPath()
    private var stdPath = UIBezierPath()
    private var minPath = UIBezierPath()
    
    private var maxLayer = CALayer()
    private var maxShape = CAShapeLayer()
    private var avgLayer = CALayer()
    private var avgShape = CAShapeLayer()
    private var stdLayer = CALayer()
    private var stdShape = CAShapeLayer()
    private var minLayer = CALayer()
    private var minShape = CAShapeLayer()
    
    var maxPoints : [CGFloat] = [140,170,200,130,70,40,60,80]
    var avgPoints : [CGFloat] = [120,140,180,110,60,35,55,60]
    var stdPoints : [CGFloat] = [20,40,80,20,40,10,40,30]
    var minPoints : [CGFloat] = [-100,-110,-150,-105,-55,-30,-53,-55]
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        //        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //        self.setup()
    }
    
    func setup(minP: [CGFloat]?, avgP: [CGFloat]?, maxP: [CGFloat]?, stdP: [CGFloat]?){
        self.relativeCenter = CGPoint(x: frame.width/2, y: frame.height/2)
        self.minR = min(frame.width,frame.height)/15
        self.maxR = max(frame.width,frame.height)/2
        self.MinMaxR = self.maxR - self.minR
        
        let MINP = self.minPoints.min()!
        let MAXP = self.maxPoints.max()!
        let MaxMinusMin = MAXP - MINP
        let scale = self.MinMaxR/MaxMinusMin
        
        self.zeroR = self.minR - scale * MINP
        
        self.minPoints = minP ?? self.minPoints
        self.avgPoints = avgP ?? self.avgPoints
        self.stdPoints = stdP ?? self.stdPoints
        self.maxPoints = maxP ?? self.maxPoints
        
//        self.maxRadius = maxPoints.map{($0 - MINP)*scale + self.minR}
        self.avgRadius = avgPoints.map{($0 - MINP)*scale + self.minR}
        self.stdPoints = stdPoints.map{($0 - MINP)*scale + self.minR}

//        self.minRadius = minPoints.map{($0 - MINP)*scale + self.minR}
        
        self.maxPath = UIBezierPath()
        self.avgPath = UIBezierPath()
        self.minPath = UIBezierPath()
        
//        let testlayer = CAShapeLayer()
//        testlayer.path = UIBezierPath(arcCenter: self.relativeCenter, radius: self.MinMaxR, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true).cgPath
//        testlayer.fillColor = UIColor.black.cgColor
//        self.layer.addSublayer(testlayer)
        
        
        var startAngle = Double.pi/80.0 - Double.pi/2
        var endAngle = Double.pi/4.0-Double.pi/80.0 - Double.pi/2
        var startAngleAvg = Double.pi/40.0 - Double.pi/2
        var endAngleAvg = Double.pi/4.0-Double.pi/20.0 - Double.pi/2

        // computing the pizza slices
        for i in 0...maxPoints.count-1 {
            self.avgPath.addArc(withCenter: self.relativeCenter, radius: self.avgRadius[i], startAngle: CGFloat(startAngleAvg) , endAngle: CGFloat(endAngleAvg), clockwise: true)
            
            let stdsublayer = CAShapeLayer()
            let stdPath = UIBezierPath(arcCenter: self.relativeCenter, radius: self.avgRadius[i], startAngle: CGFloat(startAngle) , endAngle: CGFloat(endAngle), clockwise: true)
            stdsublayer.path = stdPath.cgPath
            stdsublayer.fillColor = UIColor.clear.cgColor
            stdsublayer.strokeColor = UIColor(named: "CircularPlot3")?.cgColor
            stdsublayer.lineWidth = self.stdPoints[i]
            self.stdShape.addSublayer(stdsublayer)
            
            startAngle = endAngle
            endAngle += Double.pi/40.0
            startAngleAvg = endAngleAvg
            endAngleAvg += Double.pi/10.0

            
            self.avgPath.addArc(withCenter: self.relativeCenter, radius: self.minR, startAngle: CGFloat(startAngleAvg) , endAngle: CGFloat(endAngleAvg), clockwise: true)
            
            startAngle = endAngle
            endAngle += Double.pi/4.0 - Double.pi/40.0
            startAngleAvg = endAngleAvg
            endAngleAvg += Double.pi/4.0 - Double.pi/10.0

        }
        self.avgPath.close()
        
        
        print(self.maxR)
        self.maxPath.addArc(withCenter: self.relativeCenter, radius: self.maxR, startAngle: CGFloat(0) , endAngle: CGFloat(2*Double.pi), clockwise: true)
        self.maxPath.close()
        //        // add circle as shapelayer - sublayer of main layer
        self.maxShape.path = self.maxPath.cgPath
        self.maxShape.fillColor = UIColor(named: "CircularPlot1")?.cgColor
//        self.maxShape.opacity = 0.5
        //        self.maxLayer.strokeColor = UIColor.blue.cgColor
        //        self.maxLayer.lineWidth = 20.0
        self.layer.addSublayer(maxLayer)
        self.maxLayer.addSublayer(maxShape)
        


        
                addAnimation(delay: 0.0, Layer: self.maxLayer)
        
        self.layer.addSublayer(stdLayer)
        self.stdLayer.addSublayer(stdShape)
        
                addAnimation(delay: 0.3, Layer: self.stdLayer)
        
        self.avgShape.path = self.avgPath.cgPath
        self.avgShape.fillColor = UIColor(named: "CircularPlot2")?.cgColor
        //        self.avgLayer.strokeColor = UIColor.red.cgColor
        //        self.avgLayer.lineWidth = 10.0
        self.layer.addSublayer(avgLayer)
        self.avgLayer.addSublayer(avgShape)
        
                addAnimation(delay: 0.6, Layer: avgLayer)
        
        self.minPath.addArc(withCenter: self.relativeCenter, radius: self.minR, startAngle: CGFloat(0) , endAngle: CGFloat(2*Double.pi), clockwise: true)
        self.minPath.close()
        self.minShape.path = self.minPath.cgPath
        self.minShape.fillColor = UIColor(named: "CircularPlot3")?.cgColor
        self.layer.addSublayer(minLayer)
        self.minLayer.addSublayer(minShape)
        
                addAnimation(delay: 0.9, Layer: minLayer)
        
        let zeroShape = CAShapeLayer()
        let zeroLayer = CALayer()
        zeroShape.path = UIBezierPath(arcCenter: self.relativeCenter, radius: self.zeroR, startAngle: CGFloat(0), endAngle: CGFloat(2*Double.pi), clockwise: true).cgPath
        zeroShape.strokeColor = UIColor.black.cgColor
        zeroShape.fillColor = UIColor.clear.cgColor
        let DashPattern: [NSNumber]  = [10,3]
        zeroShape.lineDashPattern = DashPattern
        zeroShape.lineWidth = 1.0
        layer.addSublayer(zeroLayer)
        zeroLayer.addSublayer(zeroShape)
        
        let offset = CGFloat(7)
        
        drawCurvedString(on: zeroShape,text: NSAttributedString(string: "Fmax = \(MAXP)" ,attributes: [NSAttributedString.Key.foregroundColor: UIColor.black,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]),angle: -135,radius: self.maxR + offset )
        
        drawCurvedString(on: zeroShape,text: NSAttributedString(string: "zero circle" ,attributes: [NSAttributedString.Key.foregroundColor: UIColor.black,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]),angle: -135,radius: self.zeroR + offset )
        
        drawCurvedString(on: zeroShape,text: NSAttributedString(string: "Fmin = \(MINP)" ,attributes: [NSAttributedString.Key.foregroundColor: UIColor.black,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]),angle: -135,radius: self.minR + offset )

        
                addAnimation(delay: 1.2, Layer: zeroLayer)
        
    }
    
    // animation for masking layer
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
        groupAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        maskLayer.add(groupAnimation,forKey: nil)
    }
    
    
    
    
    
    
    
    func drawCurvedString(on layer: CALayer, text: NSAttributedString, angle: CGFloat, radius: CGFloat) {
        var radAngle = angle.radians
        
        let textSize = text.boundingRect(
            with: CGSize(width: .max, height: .max),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil)
            .integral
            .size
        
        let perimeter: CGFloat = 2 * .pi * radius
        let textAngle: CGFloat = textSize.width / perimeter * 2 * .pi
        
        var textRotation: CGFloat = 0
        var textDirection: CGFloat = 0
        
        if angle > CGFloat(10).radians, angle < CGFloat(170).radians {
            // bottom string
            textRotation = 0.5 * .pi
            textDirection = -2 * .pi
            radAngle += textAngle / 2
        } else {
            // top string
            textRotation = 1.5 * .pi
            textDirection = 2 * .pi
            radAngle -= textAngle / 2
        }
        
        for c in 0..<text.length {
            let letter = text.attributedSubstring(from: NSRange(c..<c+1))
            let charSize = letter.boundingRect(
                with: CGSize(width: .max, height: .max),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil)
                .integral
                .size
            
            let letterAngle = (charSize.width / perimeter) * textDirection
            let x = radius * cos(radAngle + (letterAngle / 2))
            let y = radius * sin(radAngle + (letterAngle / 2))
            
            let singleChar = drawText(
                on: layer,
                text: letter,
                frame: CGRect(
//                    x: (layer.frame.size.width / 2) - (charSize.width / 2) + x,
//                    y: (layer.frame.size.height / 2) - (charSize.height / 2) + y,
                    x: self.relativeCenter.x - (charSize.width / 2) + x,
                    y: self.relativeCenter.y - (charSize.height / 2) + y,
                    width: charSize.width,
                    height: charSize.height))
            layer.addSublayer(singleChar)
            singleChar.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: radAngle - textRotation))
            radAngle += letterAngle
        }
    }
    
    
    func drawText(on layer: CALayer, text: NSAttributedString, frame: CGRect) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.string = text
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }
    
}


extension CGFloat {
    /** Degrees to Radian **/
    var degrees: CGFloat {
        return self * (180.0 / .pi)
    }
    
    /** Radians to Degrees **/
    var radians: CGFloat {
        return self / 180.0 * .pi
    }
}


