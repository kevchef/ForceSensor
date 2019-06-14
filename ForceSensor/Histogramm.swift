//
//  Histogramm.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 14.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit

class Histogramm: BarChart {

    override init(frame: CGRect) {
        super.init(frame: frame)
        //        self.setup(barentries: [CGFloat])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        self.setup(barentries: [CGFloat])
    }
    
    override func setup(barentries: [CGFloat]){
        self.FrameWidth = frame.width
        self.FrameHeight = frame.height
        self.numberEntries = barentries.count
        self.maxEntry = barentries.max()!
        //        layer.borderColor = UIColor.black.cgColor
        //        layer.borderWidth = 5
        let elementWidth = self.FrameWidth/10
        self.barWidth = elementWidth*3.0/4.0
        self.space = elementWidth-self.barWidth

        let lines = computeHistogrammLineSegments(elementDist: elementWidth)
        for line in lines{
            layer.addLineLayer(lineSegment: line, color: UIColor(named: "CircularPlot1")!.cgColor , width: 1.0, isDashed: false, animated: true)
        }
        
        for (index, barentry) in barentries.enumerated(){
            let barFrame = computeFrame(height: barentry, i: index)
            let oldFrame = computeFrame(height: CGFloat(1), i: index)
            let Color = UIColor(named: "CircularPlot2")?.cgColor
            layer.addRectangleLayer(frame: barFrame, color: Color!, animated: true, oldFrame: oldFrame, delaymultiplier: Double(index))
            
            let bottomFrame = computeBottomFrame(i: index)
            let oldBottomFrame = computeBottomOldFrame(i: index)
            layer.addTextLayer(frame: bottomFrame, color: Color!, fontSize: 14, text: "\(index)", animated: true, oldFrame: oldBottomFrame, delaymultiplier: Double(index))
            
        }
    }
    
    override func computeBottomOldFrame(i: Int) -> CGRect{
        let xPosition: CGFloat = space + CGFloat(i) * (self.barWidth + self.space)
        let yPosition = self.FrameHeight - self.bottomSpace/2
        return CGRect(x: xPosition - self.barWidth, y: yPosition, width: 0 , height: 20)
    }
    
    override func computeBottomFrame(i: Int) -> CGRect{
        let xPosition: CGFloat = space + CGFloat(i) * (self.barWidth + self.space)
        let yPosition = self.FrameHeight - self.bottomSpace/2
        let width = self.bottomSpace/sin(CGFloat.pi/3)
        return CGRect(x: xPosition - self.barWidth, y: yPosition, width: width , height: 20)
    }
    
    func computeHistogrammLineSegments(elementDist: CGFloat) -> [LineSegment] {
        var result: [LineSegment] = []
        
        let yPosition = self.FrameHeight - self.bottomSpace
        result.append( LineSegment(startPoint: CGPoint(x:0,y:yPosition), endPoint: CGPoint(x:self.FrameWidth,y:yPosition)))
        for i in 0...10{
            let startP = CGPoint(x: CGFloat(i)*elementDist, y: yPosition + 10)
            let endP = CGPoint(x: CGFloat(i)*elementDist, y: yPosition - 10)
            result.append(LineSegment(startPoint: startP, endPoint: endP))
        }
        return result
    }
}
