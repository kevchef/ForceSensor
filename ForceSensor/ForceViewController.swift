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
    
    var F_queue: [Force] = [Force(),Force(),Force()]

    var centralManager: CBCentralManager!
    var PedalPeripheral: CBPeripheral!
    var i : CGFloat = 0.0

    @IBOutlet weak var FxLabel: UILabel!
    @IBOutlet weak var FyLabel: UILabel!
    @IBOutlet weak var FzLabel: UILabel!

    @IBOutlet weak var FC: ForceAnimationCircle!
    @IBOutlet weak var RecordButton: RecordButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func onForceMeasurementReceived(_ F: Force) {
        FxLabel.text = String((F.X+F.prevX)/2)
        FyLabel.text = String((F.Y+F.prevY)/2)
        FzLabel.text = String((F.Z+F.prevZ)/2)

        F_queue[2] = F_queue[1]
        F_queue[1] = F_queue[0]
        F_queue[0] = F
        
        FC.AnimateCircle(F_queue: F_queue)
    }
}

// extension to ForceViewController - CBCentralMangerDelegate
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

// extension to ForceViewController - CBPeripheralDelegate
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
//        DispatchQueue.main.async {
            if characteristic.uuid == ForcesCharacteristicsCBUUID{
                var F = Force()
                F = self.ForceMeasurementConversion(from: characteristic)
                self.onForceMeasurementReceived(F)
            }
//        }
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

