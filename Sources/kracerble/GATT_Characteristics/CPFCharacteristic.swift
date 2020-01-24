//
//  CPFCharacteristic.swift
//  Bluetooth
//
//  Created by nebucaz on 29.12.19.
//

import Foundation
import Bluetooth
import GATT

struct CPFFlags : OptionSet {
    let rawValue: UInt32
    static let pedalPowerBalancePresent = CPFFlags(rawValue: 1 << 0)
    static let accumulatedTorqueSupported = CPFFlags(rawValue: 1 << 1)
    static let wheelRevolutionDataSupported = CPFFlags(rawValue: 1 << 2)
    static let crankRevolutionDataSupported = CPFFlags(rawValue: 1 << 3)
    static let extremeMagnitudesSupported = CPFFlags(rawValue: 1 << 4)
    static let extremeAnglesSupported = CPFFlags(rawValue: 1 << 5)
    static let topandBottomDeadSpotAnglesSupported = CPFFlags(rawValue: 1 << 6)
    static let accumulatedEnergySupported = CPFFlags(rawValue: 1 << 7)
    static let offsetCompensationIndicatorSupported = CPFFlags(rawValue: 1 << 8)
    static let offsetCompensationSupported = CPFFlags(rawValue: 1 << 9)
    static let cyclingPowerMeasurementCharacteristicContentMaskingSupported = CPFFlags(rawValue: 1 << 10)
    static let multipleSensorLocationsSupported = CPFFlags(rawValue: 1 << 11)
    static let crankLengthAdjustmentSupported = CPFFlags(rawValue: 1 << 12)
    static let chainLengthAdjustmentSupported = CPFFlags(rawValue: 1 << 13)
    static let chainWeightAdjustmentSupported = CPFFlags(rawValue: 1 << 14)
    static let spanLengthAdjustmentSupported = CPFFlags(rawValue: 1 << 15)
    static let sensorMeasurementContext = CPFFlags(rawValue: 1 << 16)
    static let instantaneousMeasurementDirectionSupported = CPFFlags(rawValue: 1 << 17)
    static let factoryCalibrationDateSupported = CPFFlags(rawValue: 1 << 18)
    static let enhancedOffsetCompensationSupported = CPFFlags(rawValue: 1 << 19)
    static let distributeSystemSupport = CPFFlags(rawValue: 1 << 20)
}

enum CPFValueOffset : Int {
    case flags = 0
}

/// Cycling Power Feature characteristic
/// The CP Feature characteristic is used to report a list of features supported by the device.
final class CPFCharacteristic : BLECharacteristic {
    var flags : CPFFlags = []
    {
        didSet {
            withUnsafeBytes(of: flags.rawValue) {
                self.data.copy(data: Data($0), to: CPFValueOffset.flags.rawValue, size: MemoryLayout<UInt32>.size)
            }
        }
    }
    
    override init() {
        super.init()
        
        self.uuid = BluetoothUUID(rawValue: "2A65")!
        self.data = Data(count: MemoryLayout<CPFFlags>.stride)
        self.properties = [ .read ]
        self.permissions = [ .read ]
        flags = []
    }
}
