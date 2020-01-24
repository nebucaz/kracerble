//
//  BLEService.swift
//  Bluetooth
//
//  Created by nebucaz on 03.01.20.
//

import Foundation
import Bluetooth

public extension BluetoothUUID {
    
    /// Fitness Machine (`0x1826`)
    static var fitnessMachine: BluetoothUUID {
        return .bit16(0x1826)
    }
    
    /// Indoor Bike Data Characteristic
    static var indoorBikeDataCharacteristic : BluetoothUUID {
        return .bit16(0x2aD2)
    }
    
    /// convert 16 Bit BluetoothUUID to UInt16
    func toUint16() -> UInt16 {
        switch self {
        case let .bit16(value):
            return UInt16(value)
        default:
            return 0
        }
    }
}

public protocol BLEService : class {
    var uuid: BluetoothUUID { get }
    var characteristics : [BLECharacteristic] { get set }
}
