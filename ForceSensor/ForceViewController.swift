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
}

class ForceViewController: UIViewController {
    
    var ForceCircle: UIView!
    fileprivate let duration = 0.05
    fileprivate let delay = 0
    fileprivate let scale = 1.2
    var F_old = Force(prevX: 0,prevY: 0, prevZ: 0,X: 0,Y: 0,Z: 0)
    
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
        print(F_old)
        print(F)
        print("-------")
        print("-------")
        multiPosition(CGPoint(x: CGFloat(F_old.X)/1, y: CGFloat(F_old.Y)/1), CGPoint(x: CGFloat(F.X)/1, y: CGFloat(F.Y)/1) )
        F_old = F
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
        guard let characteristicData = characteristic.value else { return Force(prevX: 0,prevY: 0,prevZ: 0,X: 0,Y: 0,Z: 0) }
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
