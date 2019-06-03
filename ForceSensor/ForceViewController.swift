//
//  ViewController.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 24.05.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit
import CoreBluetooth

let CyclingPowerServiceCBUUID = CBUUID(string: "0x1818")
let ForcesServiceCBUUID = CBUUID(string: "1844")
let ForcesCharacteristicsCBUUID = CBUUID(string: "299F")
let BatteryServiceCBUUID = CBUUID(string: "0x180F")
let DeviceInfoServiceCBUUID = CBUUID(string: "0x180A")

let PedalServices = [CyclingPowerServiceCBUUID,ForcesServiceCBUUID,BatteryServiceCBUUID,DeviceInfoServiceCBUUID]

struct Force {
    var prevX = 0
    var prevY = 0
    var prevZ = 0
    var X = 0
    var Y = 0
    var Z = 0
    
    init(){
        self.prevX = 0
        self.prevY = 0
        self.prevZ = 0
        self.X = 0
        self.Y = 0
        self.Z = 0
    }
}

class ForceViewController: UIViewController {
    
    var ForceCircle: UIView!
    fileprivate let duration = 0.36
    fileprivate let delay = 0
    fileprivate let scale = 1.2
    var F_queue: [Force] = [Force(),Force(),Force()]

    var centralManager: CBCentralManager!
    var PedalPeripheral: CBPeripheral!
    var i : CGFloat = 0.0

    @IBOutlet weak var FxLabel: UILabel!
    @IBOutlet weak var FyLabel: UILabel!
    @IBOutlet weak var FzLabel: UILabel!

    @IBOutlet weak var Circle: PushButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupRect()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        Circle.setNeedsDisplay()
    }
    
    fileprivate func setupRect() {
        ForceCircle = drawCircleView()
        view.addSubview(ForceCircle)
    }
    
    fileprivate func multiPosition(_ firstPos: CGPoint, _ secondPos: CGPoint) {
        func simplePosition(_ pos: CGPoint) {
            UIView.animate(withDuration: self.duration, animations: {
                self.ForceCircle.frame.origin = pos
            }, completion: nil)
        }
        
        UIView.animate(withDuration: self.duration, animations: {
            self.ForceCircle.frame.origin = firstPos
        }, completion: { finished in
            simplePosition(secondPos)
        })
    }

    fileprivate func curvePath(_ Point1: CGPoint, Point2: CGPoint, endPoint: CGPoint) {
        let path = UIBezierPath()
//        path.move(to: self.ForceCircle.center)
        
        var alpha: CGFloat = 1.0/3.0
        var interpolationPoints: [CGPoint] = [self.ForceCircle.center, Point1, Point2, endPoint]
        guard !interpolationPoints.isEmpty else { return }
        path.move(to: interpolationPoints[0])
        
        let n = interpolationPoints.count - 1
        
        for index in 0..<n
        {
            var currentPoint = interpolationPoints[index]
            var nextIndex = (index + 1) % interpolationPoints.count
            var prevIndex = index == 0 ? interpolationPoints.count - 1 : index - 1
            var previousPoint = interpolationPoints[prevIndex]
            var nextPoint = interpolationPoints[nextIndex]
            let endPoint = nextPoint
            var mx : CGFloat
            var my : CGFloat
            
            if index > 0
            {
                mx = (nextPoint.x - previousPoint.x) / 2.0
                my = (nextPoint.y - previousPoint.y) / 2.0
            }
            else
            {
                mx = (nextPoint.x - currentPoint.x) / 2.0
                my = (nextPoint.y - currentPoint.y) / 2.0
            }
            
            let controlPoint1 = CGPoint(x: currentPoint.x + mx * alpha, y: currentPoint.y + my * alpha)
            currentPoint = interpolationPoints[nextIndex]
            nextIndex = (nextIndex + 1) % interpolationPoints.count
            prevIndex = index
            previousPoint = interpolationPoints[prevIndex]
            nextPoint = interpolationPoints[nextIndex]
            
            if index < n - 1
            {
                mx = (nextPoint.x - previousPoint.x) / 2.0
                my = (nextPoint.y - previousPoint.y) / 2.0
            }
            else
            {
                mx = (currentPoint.x - previousPoint.x) / 2.0
                my = (currentPoint.y - previousPoint.y) / 2.0
            }
            
            let controlPoint2 = CGPoint(x: currentPoint.x - mx * alpha, y: currentPoint.y - my * alpha)
            
            path.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }

        
        
        
        
        
//        path.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        // create a new CAKeyframeAnimation that animates the objects position
        let anim = CAKeyframeAnimation(keyPath: "position")
        
        // set the animations path to our bezier curve
        anim.path = path.cgPath
        
        // set some more parameters for the animation
        anim.duration = self.duration
        
        // add the animation to the squares 'layer' property
        self.ForceCircle.layer.add(anim, forKey: "animate position along path")
        self.ForceCircle.center = endPoint
    }

    func onForceMeasurementReceived(_ F: Force) {
        FxLabel.text = String((F.X+F.prevX)/2)
        FyLabel.text = String((F.Y+F.prevY)/2)
        FzLabel.text = String((F.Z+F.prevZ)/2)

//        Circle.posxFactor = CGFloat(F.X+F.prevX)/128
//        Circle.posyFactor = CGFloat(-F.Y-F.prevY)/128
//        Circle.scaleFactor = CGFloat(-F.Z-F.prevZ)/128
////        print("scaleFactor: \(Circle.scaleFactor)")
//
//        Circle.setNeedsDisplay()
        F_queue[2] = F_queue[1]
        F_queue[1] = F_queue[0]
        F_queue[0] = F
        
        print(F_queue)
        print("-------")
        print("-------")
        
        var controlPoint1 = CGPoint(x: 0, y: 0)
        controlPoint1.x += CGFloat(F_queue[2].X)
        controlPoint1.y += CGFloat(F_queue[2].Y)
        var controlPoint2 = CGPoint(x: 0, y: 0)
        controlPoint2.x += CGFloat(F_queue[1].X)
        controlPoint2.y += CGFloat(F_queue[1].Y)
        var endPoint = CGPoint(x: 0, y: 0)
        endPoint.x += CGFloat(F_queue[0].X)
        endPoint.y += CGFloat(F_queue[0].Y)
        curvePath(controlPoint1, Point2: controlPoint2, endPoint: endPoint)
//        multiPosition(CGPoint(x: CGFloat(F_old.X)/1, y: CGFloat(F_old.Y)/1), CGPoint(x: CGFloat(F.X)/1, y: CGFloat(F.Y)/1) )
//        F_old = F
    }


}


extension ForceViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: PedalServices)
        @unknown default:
            print("unknown state")
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral)
        PedalPeripheral = peripheral
        PedalPeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(PedalPeripheral, options: nil)
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected to Peripheral")
        PedalPeripheral.discoverServices(nil)
        
    }
}


extension ForceViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            if service.uuid == ForcesServiceCBUUID {
                print("Service: \(service)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == ForcesCharacteristicsCBUUID {
                peripheral.setNotifyValue(true, for:  characteristic)
//                print(characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        if characteristic.uuid == ForcesCharacteristicsCBUUID{
            var F = Force()
            F = ForceMeasurementConversion(from: characteristic)
            onForceMeasurementReceived(F)
        }
    }

    
    private func ForceMeasurementConversion(from characteristic: CBCharacteristic) -> Force {
        guard let characteristicData = characteristic.value else { return Force() }
        var F = Force()
        let byteArray = [UInt8](characteristicData)

        F.prevX = Int(byteArray[1])
        if (F.prevX & 0x80) != 0 {
            F.prevX = F.prevX - (1 << 8 ) //256
        }
        
        F.prevY = Int(byteArray[2])
        if (F.prevY & 0x80) != 0 {
            F.prevY = F.prevY - (1 << 8 ) //256
        }

        F.prevZ = ((Int(byteArray[4]) << 8) + Int(byteArray[3]))
        if (F.prevZ & 0x8000) != 0 {
            F.prevZ = F.prevZ - (1 << 16) // 65536
        }

        F.X = Int(byteArray[11])
        if (F.X & 0x80) != 0 {
            F.X = F.X - (1 << 8 ) // 256
        }

        F.Y = Int(byteArray[12])
        if (F.Y & 0x80) != 0 {
            F.Y = F.Y - (1 << 8 ) // 256
        }

        F.Z = (Int(byteArray[14]) << 8) + Int(byteArray[13])
        if (F.Z & 0x8000) != 0 {
            F.Z = F.Z - (1 <<  16) //65536
        }
        
        return F
    }
    
}





extension UIBezierPath
{
    func interpolatePointsWithHermite(interpolationPoints : [CGPoint], alpha: CGFloat = 1.0/3.0)
    {
        guard !interpolationPoints.isEmpty else { return }
        self.move(to: interpolationPoints[0])
        
        let n = interpolationPoints.count - 1
        
        for index in 0..<n
        {
            var currentPoint = interpolationPoints[index]
            var nextIndex = (index + 1) % interpolationPoints.count
            var prevIndex = index == 0 ? interpolationPoints.count - 1 : index - 1
            var previousPoint = interpolationPoints[prevIndex]
            var nextPoint = interpolationPoints[nextIndex]
            let endPoint = nextPoint
            var mx : CGFloat
            var my : CGFloat
            
            if index > 0
            {
                mx = (nextPoint.x - previousPoint.x) / 2.0
                my = (nextPoint.y - previousPoint.y) / 2.0
            }
            else
            {
                mx = (nextPoint.x - currentPoint.x) / 2.0
                my = (nextPoint.y - currentPoint.y) / 2.0
            }
            
            let controlPoint1 = CGPoint(x: currentPoint.x + mx * alpha, y: currentPoint.y + my * alpha)
            currentPoint = interpolationPoints[nextIndex]
            nextIndex = (nextIndex + 1) % interpolationPoints.count
            prevIndex = index
            previousPoint = interpolationPoints[prevIndex]
            nextPoint = interpolationPoints[nextIndex]
            
            if index < n - 1
            {
                mx = (nextPoint.x - previousPoint.x) / 2.0
                my = (nextPoint.y - previousPoint.y) / 2.0
            }
            else
            {
                mx = (currentPoint.x - previousPoint.x) / 2.0
                my = (currentPoint.y - previousPoint.y) / 2.0
            }
            
            let controlPoint2 = CGPoint(x: currentPoint.x - mx * alpha, y: currentPoint.y - my * alpha)
            
            self.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
    }
}
