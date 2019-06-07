//
//  BleManager.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 06.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

struct Force {
    var prevX = 0
    var prevY = 0
    var prevZ = 0
    var X = 0
    var Y = 0
    var Z = 0
}

class BleManager: NSObject {
    
    let CyclingPowerServiceCBUUID = CBUUID(string: "0x1818")
    let BatteryServiceCBUUID = CBUUID(string: "0x180F")
    let DeviceInfoServiceCBUUID = CBUUID(string: "0x180A")
    
    let ForcesServiceCBUUID = CBUUID(string: "1844")
    let ForcesCharacteristicsCBUUID = CBUUID(string: "299F")
    
//    let PedalServices = [CyclingPowerServiceCBUUID,ForcesServiceCBUUID,BatteryServiceCBUUID,DeviceInfoServiceCBUUID]

    // MARK: - BLE shared instance
    static let sharedInstance = BleManager()
    
    // MARK: - Properties
    
    //CoreBluetooth properties
    var centralManager: CBCentralManager!
    var activeDevice: CBPeripheral?
    var activeCharacteristic: CBCharacteristic?
    
    //UIAlert properties
    public var deviceAlert: UIAlertController?
    public var deviceSheet: UIAlertController?
    
    //Device UUID properties
    struct myDevice {
        static var ServiceUUID = CBUUID(string: "1844")
        static var CharactersticUUID = CBUUID(string: "299F")

    }
    
    var F = Force()
    // MARK: - Init method
    
    private override init() { }
}

// MARK: - CBCentralManagerDelegte protocal conformance

extension BleManager: CBCentralManagerDelegate {
    
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
            self.startScanningForDevicesWith(serviceUUID: "1844", characteristicUUID: "299F")
            print(myDevice.ServiceUUID)
        @unknown default:
            print("unknown state")
        }
    }
    
    public func startScanningForDevicesWith(serviceUUID: String, characteristicUUID: String) {
        self.disconnect()
        myDevice.ServiceUUID = CBUUID(string: serviceUUID)
        myDevice.CharactersticUUID = CBUUID(string: characteristicUUID)
//        self.createDeviceSheet()
        centralManager.scanForPeripherals(withServices: [myDevice.ServiceUUID], options: nil)
    }

    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var title = "Unknown Device"
        if (peripheral.name != nil) { title = peripheral.name!}
        print(title)
        self.centralManager.stopScan()

//        let availableDevice = UIAlertAction(title: title , style: .default, handler: {
//            action -> Void in
        self.centralManager.connect(peripheral, options: nil)
//        })
//        DispatchQueue.main.async(execute: {self.deviceSheet!.addAction(availableDevice)})
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.centralManager.stopScan()
        print("central.state is \(central.state)")
        activeDevice = peripheral
        activeDevice?.delegate = self as CBPeripheralDelegate
        activeDevice?.discoverServices([myDevice.ServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        createErrorAlert()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == activeDevice {
            print("central.state is \(central.state)")
//            clearDevices()
        }
    }
}

// MARK: - CBPeripheralDelegate protocal conformance

extension BleManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            self.createErrorAlert()
            return
        }
        guard let services = peripheral.services else { return}
        for thisService in services {
            if thisService.uuid == myDevice.ServiceUUID {
                activeDevice?.discoverCharacteristics(nil, for: thisService)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            self.createErrorAlert()
            // post notification
            return
        }
        guard let characteristics = service.characteristics else { return }
        print("peripheral.state is \(peripheral.state)")
        for thisCharacteristic in characteristics {
            if (thisCharacteristic.uuid == myDevice.CharactersticUUID) {
                activeCharacteristic = thisCharacteristic
                peripheral.setNotifyValue(true, for: activeCharacteristic!)

            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        self.createErrorAlert()
        if error != nil {
            // post notification
            return
        }

        guard let dataFromDevice = characteristic.value else { return }

        if characteristic.uuid == myDevice.CharactersticUUID {
//            postRecievedDataFromDeviceNotification()
            self.F = ForceMeasurementConversion(from: characteristic)
            print("data received")
            print(self.F)
            print(dataFromDevice)
        }

        // else if characteristic.uuid == myDevice.SecondCharacteristicUUID
        // do something...
    }
}

// MARK: - Helper methods

extension BleManager {

    // MARK: BLE Methods
    func startCentralManager() {
        let centralManagerQueue = DispatchQueue(label: "BLE queue", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralManagerQueue)
    }

    func resetCentralManger() {
        self.disconnect()
        let centralManagerQueue = DispatchQueue(label: "BLE queue", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralManagerQueue)
    }

    func disconnect() {
        if let activeCharacteristic = activeCharacteristic {
            activeDevice?.setNotifyValue(false, for: activeCharacteristic)
        }
        if let activeDevice = activeDevice {
            centralManager.cancelPeripheralConnection(activeDevice)
        }
    }

//    fileprivate func clearDevices() {
//        activeDevice = nil
//        activeCharacteristic = nil
//        myDevice.ServiceUUID = nil
//        myDevice.CharactersticUUID = nil
//    }

    // MARK: UIActionSheet Methods

    fileprivate func createDeviceSheet() {
        deviceSheet = UIAlertController(title: "Please choose a device.",
                                        message: "Connect to:", preferredStyle: .actionSheet)
        deviceSheet!.addAction(UIAlertAction(title: "Cancel", style: .cancel,
                                             handler: { action -> Void in self.centralManager.stopScan() }))
    }

    func createErrorAlert() {
        self.deviceAlert = UIAlertController(title: "Error: failed to connect.",
                                             message: "Please try again.", preferredStyle: .alert)
    }

    // MARK: NSNotificationCenter Methods

    //    fileprivate func postBLEConnectionStateNotification(_ state: BLEState) {
    //        let connectionDetails = ["currentState" : state]
    //        NotificationCenter.default.post(name: .BLE_State_Notification, object: self, userInfo: connectionDetails)
    //    }
    //
    //    fileprivate func postRecievedDataFromDeviceNotification() {
    //        NotificationCenter.default.post(name: .BLE_Data_Notification, object: self, userInfo: nil)
    //    }

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
