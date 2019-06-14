////
////  BasicBarChart.swift
////  ForceSensor
////
////  Created by Kevin Schneider on 13.06.19.
////  Copyright © 2019 Kevin Schneider. All rights reserved.
////
//
//import UIKit
//
//class BasicBarChart: UIView {
//
//    /// contain all layers of the chart
//    private let mainLayer: CALayer = CALayer()
//
//    /// contain mainLayer to support scrolling
//    private let scrollView: UIScrollView = UIScrollView()
//
//    /// A flag to indicate whether or not to animate the bar chart when its data entries changed
//    private var animated = false
//
//    /// Responsible for compute all positions and frames of all elements represent on the bar chart
//    private let presenter = BasicBarChartPresenter(barWidth: 40, space: 20)
//
//    /// An array of bar entries. Each BasicBarEntry contain information about line segments, curved line segments, positions and frames of all elements on a bar.
//    private var barEntries: [BasicBarEntry] = [] {
//        didSet {
//            print(2)
//            mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
//
////            scrollView.contentSize = CGSize(width: presenter.computeContentWidth(), height: self.frame.size.height)
//            mainLayer.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
//
//            showHorizontalLines()
//
//            for (index, entry) in barEntries.enumerated() {
//                showEntry(index: index, entry: entry, animated: animated, oldEntry: oldValue.safeValue(at: index))
//            }
//        }
//    }
//
//    func updateDataEntries(dataEntries: [DataEntry], animated: Bool) {
//        self.animated = animated
//        self.presenter.dataEntries = dataEntries
//        print(1)
//        self.barEntries = self.presenter.computeBarEntries(viewHeight: self.frame.height)
//        print(3)
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
////        setupView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
////        setupView()
//    }
//
////    private func setupView() {
////        scrollView.layer.addSublayer(mainLayer)
////        self.addSubview(scrollView)
////
////        scrollView.translatesAutoresizingMaskIntoConstraints = false
////        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
////        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
////        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
////        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
////    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.updateDataEntries(dataEntries: presenter.dataEntries, animated: false)
//    }
//
//    private func showEntry(index: Int, entry: BasicBarEntry, animated: Bool, oldEntry: BasicBarEntry?) {
//
//        let cgColor = UIColor(named: "CircularPlot1")!.cgColor
//
//        // Show the main bar
//        mainLayer.addRectangleLayer(frame: entry.barFrame, color: cgColor, animated: animated, oldFrame: oldEntry?.barFrame)
//
//        // Show an Int value above the bar
//        mainLayer.addTextLayer(frame: entry.textValueFrame, color: UIColor.black.cgColor, fontSize: 20, text: entry.data.textValue, animated: animated, oldFrame: oldEntry?.textValueFrame)
//
//        // Show a title below the bar
//        mainLayer.addTextLayer(frame: entry.bottomTitleFrame, color: cgColor, fontSize: 20, text: entry.data.title, animated: animated, oldFrame: oldEntry?.bottomTitleFrame)
//    }
//
//    private func showHorizontalLines() {
//        self.layer.sublayers?.forEach({
//            if $0 is CAShapeLayer {
//                $0.removeFromSuperlayer()
//            }
//        })
//        let lines = presenter.computeHorizontalLines(viewHeight: self.frame.height)
//        lines.forEach { (line) in
//            mainLayer.addLineLayer(lineSegment: line.segment, color: UIColor(named: "CircularPlot1")!.cgColor, width: line.width, isDashed: line.isDashed, animated: false, oldSegment: nil)
//        }
//    }
//}
//
//
//
//
//// ------- EXTENSIONS --------------
//
//// extensions to CALayer
//extension CALayer {
//    
//    func addLineLayer(lineSegment: LineSegment, color: CGColor, width: CGFloat, isDashed: Bool, animated: Bool, oldSegment: LineSegment?) {
//        let layer = CAShapeLayer()
//        layer.path = UIBezierPath(lineSegment: lineSegment).cgPath
//        layer.fillColor = UIColor.clear.cgColor
//        layer.strokeColor = color
//        layer.lineWidth = width
//        if isDashed {
//            layer.lineDashPattern = [4, 4]
//        }
//        self.addSublayer(layer)
//        
//        if animated, let segment = oldSegment {
//            layer.animate(
//                fromValue: UIBezierPath(lineSegment: segment).cgPath,
//                toValue: layer.path!,
//                keyPath: "path")
//        }
//    }
//    
//    func addTextLayer(frame: CGRect, color: CGColor, fontSize: CGFloat, text: String, animated: Bool, oldFrame: CGRect?) {
//        let textLayer = CATextLayer()
//        textLayer.frame = frame
//        textLayer.foregroundColor = color
//        textLayer.backgroundColor = UIColor.clear.cgColor
//        textLayer.alignmentMode = CATextLayerAlignmentMode.center
//        textLayer.contentsScale = UIScreen.main.scale
//        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
//        textLayer.fontSize = fontSize
//        textLayer.string = text
//        self.addSublayer(textLayer)
//        
//        if animated, let oldFrame = oldFrame {
//            // "frame" property is not animatable in CALayer, so, I use "position" instead
//            // Position is at the center of the frame (if you don't change the anchor point)
//            let oldPosition = CGPoint(x: oldFrame.midX, y: oldFrame.midY)
//            textLayer.animate(fromValue: oldPosition, toValue: textLayer.position, keyPath: "position")
//        }
//    }
//    
//    func addCircleLayer(origin: CGPoint, radius: CGFloat, color: CGColor, animated: Bool, oldOrigin: CGPoint?) {
//        let layer = CALayer()
//        layer.frame = CGRect(x: origin.x, y: origin.y, width: radius * 2, height: radius * 2)
//        layer.backgroundColor = color
//        layer.cornerRadius = radius
//        self.addSublayer(layer)
//        
//        if animated, let oldOrigin = oldOrigin {
//            let oldFrame = CGRect(x: oldOrigin.x, y: oldOrigin.y, width: radius * 2, height: radius * 2)
//            
//            // "frame" property is not animatable in CALayer, so, I use "position" instead
//            layer.animate(fromValue: CGPoint(x: oldFrame.midX, y: oldFrame.midY),
//                          toValue: CGPoint(x: layer.frame.midX, y: layer.frame.midY),
//                          keyPath: "position")
//        }
//    }
//    
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
//}
//
//
//
//// extensions to UIBezierPath
//extension UIBezierPath {
//    convenience init(lineSegment: LineSegment) {
//        self.init()
//        self.move(to: lineSegment.startPoint)
//        self.addLine(to: lineSegment.endPoint)
//    }
//}
//
//// extensions to UIBezierPath
//extension Array {
//    func safeValue(at index: Int) -> Element? {
//        if index < self.count {
//            return self[index]
//        } else {
//            return nil
//        }
//    }
//}
