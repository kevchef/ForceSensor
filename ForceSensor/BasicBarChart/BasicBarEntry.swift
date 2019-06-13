//
//  BasicBarEntry.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 13.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry
import UIKit

struct BasicBarEntry {
    let origin: CGPoint
    let barWidth: CGFloat
    let barHeight: CGFloat
    let space: CGFloat
    let data: DataEntry
    
    var bottomTitleFrame: CGRect {
        return CGRect(x: origin.x - space/2, y: origin.y + 10 + barHeight, width: barWidth + space, height: 22)
    }
    
    var textValueFrame: CGRect {
        return CGRect(x: origin.x - space/2, y: origin.y - 30, width: barWidth + space, height: 22)
    }
    
    var barFrame: CGRect {
        return CGRect(x: origin.x, y: origin.y, width: barWidth, height: barHeight)
    }
}


struct HorizontalLine {
    let segment: LineSegment
    let isDashed: Bool
    let width: CGFloat
}

struct DataEntry {
    let color: UIColor
    
    /// Ranged from 0.0 to 1.0
    let height: Float
    
    /// To be shown on top of the bar
    let textValue: String
    
    /// To be shown at the bottom of the bar
    let title: String
}

struct LineSegment {
    let startPoint: CGPoint
    let endPoint: CGPoint
}

