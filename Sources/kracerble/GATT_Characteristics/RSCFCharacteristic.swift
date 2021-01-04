//
//  RSCFCharacteristic.swift
//  kracerble
//
//  Created by neo on 22.11.20.
//  Copyright © 2020 page.agent. All rights reserved.
//
//

import Foundation
import Bluetooth
import GATT

struct RSCFFlags : OptionSet {
    let rawValue: UInt16

    static let instantaneousStrideLengthMeasurementSupported = RSCFFlags(rawValue: 1 << 0)
    static let totalDistanceMeasurementSupported = RSCFFlags(rawValue: 1 << 1)
    static let walkingOrRunningStatusSupported = RSCFFlags(rawValue: 1 << 2)
    static let sensorCalibrationProcedureSupported = RSCFFlags(rawValue: 1 << 3)
    static let multipleSensorLocationSupported = RSCFFlags(rawValue: 1 << 4)
}

enum RSCFValueOffset : Int {
    case flags = 0
}

/// Running Speed & Cadence Feature characteristic
/// The RSC Feature characteristic is used to report a list of features supported by the device.
final class RSCFCharacteristic : BLECharacteristic {
    var flags : RSCFFlags = []
    {
        didSet {
            withUnsafeBytes(of: flags.rawValue) {
                self.data.copy(data: Data($0), to: RSCFValueOffset.flags.rawValue, size: MemoryLayout<UInt32>.size)
            }
        }
    }
    
    override init() {
        super.init()
        
        self.uuid = BluetoothUUID(rawValue: "2A54")!
        self.data = Data(count: MemoryLayout<RSCFFlags>.stride)
        self.properties = [ .read ]
        self.permissions = [ .read ]
        flags = []
    }
}
