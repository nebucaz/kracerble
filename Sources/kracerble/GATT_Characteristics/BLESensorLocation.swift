//
//  SensorLocation.swift
//  Bluetooth
//
//  Created by nebucaz on 04.01.20.
//

import Foundation
import Bluetooth

enum SensorLocation : UInt8 {
    case other = 0
    case topOfShoe, inShoe, hip, frontWheel, leftCrank, rightCrank, leftPedal, rightPedal, frontHub, rearDropout, chainstay, rearWheel, rearHub, chest, spider, chainRing
}

final class BLESensorLocation : BLECharacteristic {
    
    var sensorLocation : SensorLocation = .other
    {
        didSet {
            withUnsafeBytes(of: sensorLocation) {
                self.data.copy(data: Data($0), to: 0, size: MemoryLayout<UInt8>.size)
            }
        }
    }
    
    override init() {
        super.init()
        
        self.uuid = BluetoothUUID(rawValue: "2A5D")!
        self.data = Data(count: MemoryLayout<SensorLocation>.stride)
        self.properties = [ .read ]
        self.permissions = [ .read ]
        
        sensorLocation = .other
    }
}
