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

struct Measurement {
    var prevCrankAngle = 0
    var prevX = 0
    var prevY = 0
    var prevZ = 0
    var prevPedalAngle = 0
//    var prevVelX = 0
//    var prevVelZ = 0
    
    var CrankAngle = 0
    var X = 0
    var Y = 0
    var Z = 0
    var PedalAngle = 0
//    var VelX = 0
//    var VelZ = 0
}

class BLE: NSObject {
    
    // MARK: - BLE shared instance
    static let sharedInstance = BLE()
    let StartupDate = Date()
    
    // MARK: - Properties
    //CoreBluetooth properties
    var centralManager: CBCentralManager!
    var styxLeft: CBPeripheral?
    var styxRight: CBPeripheral?
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
    var M_left = Measurement()
    var M_right = Measurement()

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
        if ( title == "STYX_DEMO_LX"){
            self.styxLeft = peripheral //
            self.styxLeft?.delegate = self //
            self.centralManager.connect(peripheral,
                                        options: nil) // change to [CBConnectPeripheralOptionNotifyOnNotificationKey : true]) if you want to be alerted each time exiting the application
        }
        else if (title == "STYX_DEMO_RX" ){
            self.styxRight = peripheral //
            self.styxRight?.delegate = self //
            self.centralManager.connect(peripheral,
                                        options: nil)
        }
        
//        })

    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let peripherals = central.retrieveConnectedPeripherals(withServices: [constants.ForcesServiceCBUUID] )
        if (peripherals.count >= 2) {
            centralManager.stopScan()
            print("stop scanning")
        }
//        postBLEConnectionStateNotification(.connecting)
        print("central is .connected")
//        activeDevice = peripheral
//        activeDevice?.delegate = self
        styxLeft?.discoverServices([myDevice.ServiceUUID!])
        styxRight?.discoverServices([myDevice.ServiceUUID!])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        self.createErrorAlert()
        print("failed to connect")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == styxLeft {
//            postBLEConnectionStateNotification(.disconnected)
            print("central.state is .disconnected from styxLeft")
            clearDevices()
        }
        if peripheral == styxRight {
            //            postBLEConnectionStateNotification(.disconnected)
            print("central.state is .disconnected from styxRight")
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
                styxLeft?.discoverCharacteristics(nil, for: thisService)
                styxRight?.discoverCharacteristics(nil, for: thisService)
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
        if error != nil {
            // post notification
            print("something went wrong while didUpdateValueFor - error != nil")
            return
        }
        
        if( peripheral == styxLeft){
            print("peripheral  - didUpdateValueFor styxLeft")
            if characteristic.uuid == myDevice.CharactersticUUID {
                self.M_left = self.MeasurementConversion(from: characteristic)
                postRecievedDataFromLEFTDeviceNotification()
            }
        }
        else if( peripheral == styxRight){
            print("peripheral  - didUpdateValueFor styxRight")
            if characteristic.uuid == myDevice.CharactersticUUID {
                self.M_right = self.MeasurementConversion(from: characteristic)
                postRecievedDataFromRIGHTDeviceNotification()
            }

        }
        else{ print("updated for unknown device") }
    }
}

// MARK: - Helper methods

extension BLE {
    
    // MARK: BLE Methods
    func getMleft() -> Measurement{
        return self.M_left
    }
    
    func getMright() -> Measurement{
        return self.M_right
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
            styxLeft?.setNotifyValue(false, for: activeCharacteristic)
            styxRight?.setNotifyValue(false, for: activeCharacteristic)

        }
        if let activeDevice = styxLeft {
            centralManager.cancelPeripheralConnection(activeDevice)
        }
    }
    
    fileprivate func clearDevices() {
        styxLeft = nil
        styxRight = nil
        activeCharacteristic = nil
        myDevice.ServiceUUID = nil
        myDevice.CharactersticUUID = nil
    }
    
    // MARK: UIActionSheet Methods
    
    fileprivate func createDeviceSheet() {
        print("creating device sheet")
        deviceSheet = UIAlertController(title: "Please choose a device.",
                                        message: "Connect to:", preferredStyle: .actionSheet)
        deviceSheet!.addAction(UIAlertAction(title: "Cancel", style: .cancel,
                                             handler: { action -> Void in self.centralManager.stopScan() }))
    }
    
    fileprivate func createErrorAlert() {
        deviceAlert = UIAlertController(title: "Error: failed to connect.",
                                        message: "Please try again.", preferredStyle: .alert)
        print("UIAlertController")
    }
    
    // MARK: NSNotificationCenter Methods
    
//    fileprivate func postBLEConnectionStateNotification(_ state: BLEState) {
//        let connectionDetails = ["currentState" : state]
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "BLE_State_Notification"), object: self, userInfo: connectionDetails)
//    }

//    fileprivate func postRecievedDataFromDeviceNotification() {
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "BLE_Data_Notification"), object: self, userInfo: nil)
//    }
    
    
    fileprivate func postRecievedDataFromLEFTDeviceNotification() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BLE_LEFTForceMeasurementUpdated"), object: self, userInfo: nil)
    }
    
    fileprivate func postRecievedDataFromRIGHTDeviceNotification() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BLE_RIGHTForceMeasurementUpdated"), object: self, userInfo: nil)
    }

    private func MeasurementConversion(from characteristic: CBCharacteristic) -> Measurement {
        guard let characteristicData = characteristic.value else { return Measurement() }
        var M = Measurement()
        let byteArray = [UInt8](characteristicData)
        
        // previous Measurements
        M.prevCrankAngle = Int(byteArray[0])
        if (M.prevCrankAngle & 0x80) != 0 {
            M.prevCrankAngle = M.prevCrankAngle - (1 << 8 ) //256
        }

        M.prevX = Int(byteArray[1])
        if (M.prevX & 0x80) != 0 {
            M.prevX = M.prevX - (1 << 8 ) //256
        }

        M.prevY = Int(byteArray[2])
        if (M.prevY & 0x80) != 0 {
            M.prevY = M.prevY - (1 << 8 ) //256
        }

        M.prevZ = ((Int(byteArray[4]) << 8) + Int(byteArray[3]))
        if (M.prevZ & 0x8000) != 0 {
            M.prevZ = M.prevZ - (1 << 16) // 65536
        }
        
        M.prevPedalAngle = Int(byteArray[5])
        if (M.prevPedalAngle & 0x80) != 0 {
            M.prevPedalAngle = M.prevPedalAngle - (1 << 8 ) //256
        }

//        M.prevVelX = ((Int(byteArray[7]) << 8) + Int(byteArray[6]))
//        if (M.prevVelX & 0x8000) != 0 {
//            M.prevVelX = M.prevVelX - (1 << 16) // 65536
//        }
//
//        M.prevVelZ = ((Int(byteArray[9]) << 8) + Int(byteArray[8]))
//        if (M.prevVelZ & 0x8000) != 0 {
//            M.prevVelZ = M.prevVelZ - (1 << 16) // 65536
//        }
        
        // current measurements
        M.PedalAngle = Int(byteArray[5])
        if (M.PedalAngle & 0x80) != 0 {
            M.PedalAngle = M.PedalAngle - (1 << 8 ) //256
        }
        
        M.X = Int(byteArray[11])
        if (M.X & 0x80) != 0 {
            M.X = M.X - (1 << 8 ) // 256
        }

        M.Y = Int(byteArray[12])
        if (M.Y & 0x80) != 0 {
            M.Y = M.Y - (1 << 8 ) // 256
        }

        M.Z = (Int(byteArray[14]) << 8) + Int(byteArray[13])
        if (M.Z & 0x8000) != 0 {
            M.Z = M.Z - (1 <<  16) //65536
        }
        
        M.PedalAngle = Int(byteArray[15])
        if (M.PedalAngle & 0x80) != 0 {
            M.PedalAngle = M.PedalAngle - (1 << 8 ) // 256
        }

//        M.VelX = ((Int(byteArray[17]) << 8) + Int(byteArray[16]))
//        if (M.VelX & 0x8000) != 0 {
//            M.VelX = M.VelX - (1 << 16) // 65536
//        }
//
//        M.VelZ = ((Int(byteArray[19]) << 8) + Int(byteArray[18]))
//        if (M.VelZ & 0x8000) != 0 {
//            M.VelZ = M.VelZ - (1 << 16) // 65536
//        }


        return M
    }
}








