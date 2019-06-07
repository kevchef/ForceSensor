//
//  Constants.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 07.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import Foundation
import CoreBluetooth

struct constants {
//    static let myServiceUUID = "00001524-2c44-43e6-fbae-644db9ec1443"
//    static let myCharacteristicUUID = "00001524-2c44-43e6-fbae-644db9ec9348"
    static let CyclingPowerServiceCBUUID = CBUUID(string: "0x1818")
    static let ForcesServiceCBUUID = CBUUID(string: "1844")
    static let ForcesCharacteristicsCBUUID = CBUUID(string: "299F")
    static let BatteryServiceCBUUID = CBUUID(string: "0x180F")
    static let DeviceInfoServiceCBUUID = CBUUID(string: "0x180A")

}

enum BLEState:String {
    case connected
    case disconnected
    case connecting
}
