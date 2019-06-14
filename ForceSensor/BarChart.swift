//
//  BarChart.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 14.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit

class BarChart: UIView {
    
    var barentries = [100, 80, 60, 40 , 20, 40, 80, 20]
    var FrameHeight = CGFloat(100)
    var FrameWidth = CGFloat(100)
    var numberEntries = Int(5)
    var maxEntry = CGFloat(10)
    
    var barWidth = CGFloat(20)
    var space = CGFloat(15)
    let bottomSpace = CGFloat(50)
    let topSpace = CGFloat(20)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.setup(barentries: [CGFloat])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        self.setup(barentries: [CGFloat])
    }

    func setup(barentries: [CGFloat]){
        self.FrameWidth = frame.width
        self.FrameHeight = frame.height
        self.numberEntries = barentries.count
        self.maxEntry = barentries.max()!
//        layer.borderColor = UIColor.black.cgColor
//        layer.borderWidth = 5
        
        
        let HorizontalLines = computeHorizontalLines()
        HorizontalLines.forEach { (line) in
            let Color = UIColor(named: "CircularPlot1")?.cgColor
            layer.addLineLayer(lineSegment: line.segment, color: Color!, width: line.width, isDashed: line.isDashed, animated: true)

        }
        
        for (index, barentry) in barentries.enumerated(){
            let barFrame = computeFrame(height: barentry, i: index)
            let oldFrame = computeFrame(height: CGFloat(1), i: index)
            let Color = UIColor(named: "CircularPlot2")?.cgColor
            layer.addRectangleLayer(frame: barFrame, color: Color!, animated: true, oldFrame: oldFrame, delaymultiplier: Double(index))
            
            let bottomFrame = computeBottomFrame(i: index)
            let oldBottomFrame = computeBottomOldFrame(i: index)
            layer.addTextLayer(frame: bottomFrame, color: Color!, fontSize: 14, text: "Session: \(index+1)", animated: true, oldFrame: oldBottomFrame, delaymultiplier: Double(index))

        }
    }
    
    func computeBottomOldFrame(i: Int) -> CGRect{
        let xPosition: CGFloat = space + CGFloat(i) * (self.barWidth + self.space)
        let yPosition = self.FrameHeight - self.bottomSpace/2
        return CGRect(x: xPosition - self.space, y: yPosition - 5, width: 0 , height: 20)
    }
    
    func computeBottomFrame(i: Int) -> CGRect{
        let xPosition: CGFloat = space + CGFloat(i) * (self.barWidth + self.space)
        let yPosition = self.FrameHeight - self.bottomSpace/2
        let width = self.bottomSpace/sin(CGFloat.pi/3)
        return CGRect(x: xPosition - self.space, y: yPosition - 5, width: width , height: 20)
    }
    
    func computeFrame(height: CGFloat, i: Int) -> CGRect{
        let entryHeight = height/self.maxEntry * (self.FrameHeight - self.bottomSpace - self.topSpace)
        let xPosition: CGFloat = space/2 + CGFloat(i) * (self.barWidth + self.space)
        let yPosition = self.FrameHeight - entryHeight - self.bottomSpace
        
        return CGRect(x: xPosition, y: yPosition, width: self.barWidth, height: entryHeight)
    }
    
    
    func computeHorizontalLines() -> [Line] {
        var result: [Line] = []
        
        let horizontalLineInfos = [
            (value: CGFloat(0.0), isDashed: false),
            (value: CGFloat(0.5), isDashed: true),
            (value: CGFloat(1.0), isDashed: true)
        ]
        
        for lineInfo in horizontalLineInfos {
            let yPosition = self.FrameHeight - self.bottomSpace -  lineInfo.value * (self.FrameHeight - self.bottomSpace - self.topSpace)
            
            let length = self.FrameWidth
            let lineSegment = LineSegment(
                startPoint: CGPoint(x: 0, y: yPosition),
                endPoint: CGPoint(x: length, y: yPosition)
            )
            let line = Line(
                segment: lineSegment,
                isDashed: lineInfo.isDashed,
                width: 1)
            result.append(line)
        }
        
        return result
    }

}


// ------- EXTENSIONS --------------

// extensions to CALayer
extension CALayer {

    func addRectangleLayer(frame: CGRect, color: CGColor, animated: Bool, oldFrame: CGRect, delaymultiplier: Double) {
        let layer = CALayer()
        layer.frame = oldFrame
        layer.backgroundColor = UIColor.clear.cgColor
        self.addSublayer(layer)
        
        layer.frame = frame
        
        let delay = 0.1
        
        if animated {
            layer.animate(fromValue: UIColor.clear.cgColor, toValue: color, keyPath: "backgroundColor", duration: 0.1, delay: delay*delaymultiplier)
            layer.animate(fromValue: CGPoint(x: oldFrame.midX, y: oldFrame.midY), toValue: layer.position, keyPath: "position", duration: 0.5, delay: delay*delaymultiplier)
            layer.animate(fromValue: CGRect(x: 0, y: 0, width: oldFrame.width, height: oldFrame.height), toValue: layer.bounds, keyPath: "bounds", duration: 0.5, delay: delay*delaymultiplier)
        }
    }
    
    func addLineLayer(lineSegment: LineSegment, color: CGColor, width: CGFloat, isDashed: Bool, animated: Bool) {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(lineSegment: lineSegment).cgPath

        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color
        layer.lineWidth = width
        
        if isDashed {
            layer.lineDashPattern = [4, 4]
        }
        
        self.addSublayer(layer)
        
        let segment = LineSegment(startPoint: lineSegment.startPoint, endPoint: lineSegment.startPoint)
        if animated {
            layer.animate(
                fromValue: UIBezierPath(lineSegment: segment).cgPath,
                toValue: layer.path!,
                keyPath: "path", duration: 1.5, delay: 0)
        }
    }
    
    func addTextLayer(frame: CGRect, color: CGColor, fontSize: CGFloat, text: String, animated: Bool, oldFrame: CGRect, delaymultiplier: Double) {
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.foregroundColor = UIColor.clear.cgColor

        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.left
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = fontSize
        textLayer.string = text
        textLayer.transform = CATransform3DMakeRotation(CGFloat.pi/3, 0.0, 0.0, 1.0);
        self.addSublayer(textLayer)

//        let blockLayer = CAShapeLayer()
//        blockLayer.frame = frame
//        blockLayer.transform = CATransform3DMakeRotation(CGFloat.pi/3, 0.0, 0.0, 1.0);
//        blockLayer.backgroundColor = UIColor.white.cgColor
//        self.addSublayer(blockLayer)
        
        if animated{
            // "frame" property is not animatable in CALayer, so, I use "position" instead
            // Position is at the center of the frame (if you don't change the anchor point)
            textLayer.animate(fromValue: UIColor.clear.cgColor, toValue: color, keyPath: "foregroundColor", duration: 0.5, delay: 0.1*delaymultiplier)
//            blockLayer.animate(fromValue: frame, toValue: oldFrame, keyPath: "bounds", duration: 0.3, delay: 0.1*delaymultiplier)
        }
    }
    
    func animate(fromValue: Any, toValue: Any, keyPath: String, duration: CFTimeInterval, delay: CFTimeInterval) {
        let anim = CABasicAnimation(keyPath: keyPath)
        anim.fromValue = fromValue
        anim.toValue = toValue
        anim.duration = duration
        anim.isRemovedOnCompletion = false
        anim.fillMode = CAMediaTimingFillMode.forwards
        anim.beginTime = CACurrentMediaTime() + delay
        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.add(anim, forKey: keyPath)
    }

}


// Line segment, struct and UIBEzierPAth extensions
struct Line {
    let segment: LineSegment
    let isDashed: Bool
    let width: CGFloat
}

struct LineSegment {
    let startPoint: CGPoint
    let endPoint: CGPoint
}

extension UIBezierPath {
    convenience init(lineSegment: LineSegment) {
        self.init()
        self.move(to: lineSegment.startPoint)
        self.addLine(to: lineSegment.endPoint)
    }
}
