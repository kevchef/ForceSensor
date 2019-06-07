//
//  BLE.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 07.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

class BLE: NSObject {
    
    // MARK: - BLE shared instance
    static let sharedInstance = BLE()
    
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
        static var ServiceUUID: CBUUID?
        static var CharactersticUUID: CBUUID?
    }
    
    //ble measurement storage variable
    var F = Force()
    // MARK: - Init method
    
    private override init() { }
}

// MARK: - CBCentralManagerDelegte protocal conformance

extension BLE: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("central.state is .poweredOn")
            self.startScanningForDevicesWith(serviceUUID: constants.ForcesServiceCBUUID, characteristicUUID: constants.ForcesCharacteristicsCBUUID)
        case .poweredOff:
            print("central.state is .poweredOff")
            print("clearDevices()")
            self.clearDevices()
        case .resetting:
            print("disconnect()")
            self.disconnect()
        case .unauthorized: break
        case .unsupported: break
        case .unknown:   break
        @unknown default:
            fatalError("not known case")
        }
    }
    
    public func startScanningForDevicesWith(serviceUUID: CBUUID, characteristicUUID: CBUUID) {
        self.disconnect()
        myDevice.ServiceUUID = serviceUUID//CBUUID(string: serviceUUID)
        myDevice.CharactersticUUID = characteristicUUID//CBUUID(string: characteristicUUID)
        self.createDeviceSheet()
        centralManager.scanForPeripherals(withServices: [myDevice.ServiceUUID!], options: nil)
        print("central is scaning for peripherals")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var title = "Unknown Device"
        if (peripheral.name != nil) { title = peripheral.name!}
        print("central didDiscover peripheral")
        print(title)
//        let availableDevice = UIAlertAction(title: title , style: .default, handler: {
//            action -> Void in
            print("central - trying to connect")
            activeDevice = peripheral //
            activeDevice?.delegate = self //
            self.centralManager.connect(peripheral,
                                        options: [CBConnectPeripheralOptionNotifyOnNotificationKey : true])
//        })

    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager.stopScan()
//        postBLEConnectionStateNotification(.connecting)
        print("central is .connected")
//        activeDevice = peripheral
//        activeDevice?.delegate = self
        activeDevice?.discoverServices([myDevice.ServiceUUID!])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        self.createErrorAlert()
        print("failed to connect")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == activeDevice {
//            postBLEConnectionStateNotification(.disconnected)
            print("central.state is .disconnected")
            clearDevices()
        }
    }
}

// MARK: - CBPeripheralDelegate protocal conformance

extension BLE: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
//            self.createErrorAlert()
            print("something went wrong while didDiscoverServices - error != 0")
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
//            self.createErrorAlert()
            print("something went wrong in didDiscoverCharacteristicFor - error != nil")
            // post notification
            return
        }
        guard let characteristics = service.characteristics else { return }
//        postBLEConnectionStateNotification(.connected)
        print("peripheral is .connected")
        for thisCharacteristic in characteristics {
            if (thisCharacteristic.uuid == myDevice.CharactersticUUID) {
                activeCharacteristic = thisCharacteristic
                peripheral.setNotifyValue(true, for: activeCharacteristic!)
                
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        self.createErrorAlert() //printing a lot of Error messages which I cannot interpret
        print("peripheral  - didUpdateValueFor")
        if error != nil {
            // post notification
            print("something went wrong while didUpdateValueFor - error != nil")
            return
        }
        
//        guard let dataFromDevice = characteristic.value else { return }
        
        if characteristic.uuid == myDevice.CharactersticUUID {
//            postRecievedDataFromDeviceNotification()
            self.F = self.ForceMeasurementConversion(from: characteristic)
            postRecievedDataFromDeviceNotification()
//            self.onForceMeasurementReceived(F)
//            print(F)
        }
        
        // else if characteristic.uuid == myDevice.SecondCharacteristicUUID
        // do something...
    }
}

// MARK: - Helper methods

extension BLE {
    
    // MARK: BLE Methods
    func getF() -> Force{
        return self.F
    }
    
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
    
    fileprivate func clearDevices() {
        activeDevice = nil
        activeCharacteristic = nil
        myDevice.ServiceUUID = nil
        myDevice.CharactersticUUID = nil
    }
    
    // MARK: UIActionSheet Methods
    
    fileprivate func createDeviceSheet() {
        deviceSheet = UIAlertController(title: "Please choose a device.",
                                        message: "Connect to:", preferredStyle: .actionSheet)
        deviceSheet!.addAction(UIAlertAction(title: "Cancel", style: .cancel,
                                             handler: { action -> Void in self.centralManager.stopScan() }))
    }
    
    fileprivate func createErrorAlert() {
        deviceAlert = UIAlertController(title: "Error: failed to connect.",
                                        message: "Please try again.", preferredStyle: .alert)
    }
    
    // MARK: NSNotificationCenter Methods
    
//    fileprivate func postBLEConnectionStateNotification(_ state: BLEState) {
//        let connectionDetails = ["currentState" : state]
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "BLE_State_Notification"), object: self, userInfo: connectionDetails)
//    }

//    fileprivate func postRecievedDataFromDeviceNotification() {
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "BLE_Data_Notification"), object: self, userInfo: nil)
//    }
    
    
    fileprivate func postRecievedDataFromDeviceNotification() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BLE_ForceMeasurementUpdated"), object: self, userInfo: nil)
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








