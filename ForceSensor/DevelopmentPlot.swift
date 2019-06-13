//
//  DevelopmentPlot.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 12.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit

class DevelopmentPlot: UIView {
    
        override init(frame: CGRect) {
    
            super.init(frame: frame)
    
            self.setup()
        }
    
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
    
            self.setup()
        }
    

    func setup(){
        let framewidth = self.frame.width
        let numberBars = 10
        
        let seperationWidth = 15
        let barwidth = (Int(framewidth)-seperationWidth*numberBars)/numberBars
        let barheightmax = self.frame.height
        
        for i in 0...numberBars-1{
            let startpoint = i*(barwidth+seperationWidth)
            let layer = CAShapeLayer()
            layer.path = UIBezierPath(roundedRect: CGRect(x: CGFloat(startpoint), y: CGFloat(0), width: CGFloat(barwidth), height: CGFloat(barheightmax/2)), cornerRadius: 0).cgPath
            layer.fillColor = UIColor.red.cgColor
            self.layer.addSublayer(layer)
            
        }
        
    }
    
}




//
//struct BasicBarEntry {
//    let origin: CGPoint
//    let barWidth: CGFloat
//    let barHeight: CGFloat
//    let space: CGFloat
//
//    var bottomTitleFrame: CGRect {
//        return CGRect(x: origin.x - space/2, y: origin.y + 10 + barHeight, width: barWidth + space, height: 22)
//    }
//
//    var textValueFrame: CGRect {
//        return CGRect(x: origin.x - space/2, y: origin.y - 30, width: barWidth + space, height: 22)
//    }
//
//    var barFrame: CGRect {
//        return CGRect(x: origin.x, y: origin.y, width: barWidth, height: barHeight)
//    }
//}
//
//class DevelopmentPlot: UIView {
//
//    var developementData = [100,150,200,120,140,80,180]
//    private let mainLayer: CALayer = CALayer()
//    private var animated = false
//    private let presenter = BasicBarChartPresenter(barWidth: 40, space: 20)
//
//
//    override init(frame: CGRect) {
//
//        super.init(frame: frame)
//
////        self.setup()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
////        self.setup()
//    }
//
//    private var barEntries: [BasicBarEntry] = [] {
//        didSet {
//            mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
//
////            scrollView.contentSize = CGSize(width: presenter.computeContentWidth(), height: self.frame.size.height)
//            mainLayer.frame = self.frame
//
////            showHorizontalLines()
//
//            for (index, entry) in barEntries.enumerated() {
//                showEntry(index: index, entry: entry, animated: animated, oldEntry: oldValue.safeValue(at: index))
//            }
//        }
//    }
//
//    private func showEntry(index: Int, entry: BasicBarEntry, animated: Bool, oldEntry: BasicBarEntry?) {
//
////        let cgColor = entry.data.color.cgColor
//        guard let cgColor = UIColor(named: "CircularPlot2")!.cgColor
//
//        // Show the main bar
//        mainLayer.addRectangleLayer(frame: entry.barFrame, color: cgColor, animated: animated, oldFrame: oldEntry?.barFrame)
//
//        // Show an Int value above the bar
////        mainLayer.addTextLayer(frame: entry.textValueFrame, color: cgColor, fontSize: 14, text: entry.data.textValue, animated: animated, oldFrame: oldEntry?.textValueFrame)
//
//        // Show a title below the bar
////        mainLayer.addTextLayer(frame: entry.bottomTitleFrame, color: cgColor, fontSize: 14, text: entry.data.title, animated: animated, oldFrame: oldEntry?.bottomTitleFrame)
//    }
//
//}
//
//
//
//class Presenter{
//    let barWidth: CGFloat
//
//    /// the space between bars
//    let space: CGFloat
//
//    func computeBarEntries(viewHeight: CGFloat) -> [BasicBarEntry] {
//        var result: [BasicBarEntry] = []
//
//        for (index, entry) in dataEntries.enumerated() {
//            let entryHeight = CGFloat(entry.height) * (viewHeight - bottomSpace - topSpace)
//            let xPosition: CGFloat = space + CGFloat(index) * (barWidth + space)
//            let yPosition = viewHeight - bottomSpace - entryHeight
//            let origin = CGPoint(x: xPosition, y: yPosition)
//
//            let barEntry = BasicBarEntry(origin: origin, barWidth: barWidth, barHeight: entryHeight, space: space, data: entry)
//
//            result.append(barEntry)
//        }
//        return result
//    }
//}
//
//
//
//
//
//
//
//extension CALayer {
//    func addRectangleLayer(frame: CGRect, color: CGColor, animated: Bool, oldFrame: CGRect?) {
//        let layer = CALayer()
//        layer.frame = frame
//        layer.backgroundColor = color
//        self.addSublayer(layer)
//
//        if animated, let oldFrame = oldFrame {
//            layer.animate(fromValue: CGPoint(x: oldFrame.midX, y: oldFrame.midY), toValue: layer.position, keyPath: "position")
//            layer.animate(fromValue: CGRect(x: 0, y: 0, width: oldFrame.width, height: oldFrame.height), toValue: layer.bounds, keyPath: "bounds")
//        }
//    }
//
//    func animate(fromValue: Any, toValue: Any, keyPath: String) {
//        let anim = CABasicAnimation(keyPath: keyPath)
//        anim.fromValue = fromValue
//        anim.toValue = toValue
//        anim.duration = 0.5
//        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        self.add(anim, forKey: keyPath)
//    }
//
//}
//
//
//extension Array {
//    func safeValue(at index: Int) -> Element? {
//        if index < self.count {
//            return self[index]
//        } else {
//            return nil
//        }
//    }
//}
