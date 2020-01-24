//
//  CPMFlags.swift
//  Bluetooth
//
//  Created by nebucaz on 28.12.19.
//

import Foundation
import Bluetooth
import GATT

struct CPMFlags : OptionSet {
    let rawValue: UInt16
    
    static let pedalPowerBalancePresent = CPMFlags(rawValue: 1 << 0)
    static let pedalPowerBalanceReference = CPMFlags(rawValue: 1 << 1)
    static let accumulatedTorquePresent = CPMFlags(rawValue: 1 << 2)
    static let accumulatedTorqueSource = CPMFlags(rawValue: 1 << 3)
    static let wheelRevolutionDataPresent = CPMFlags(rawValue: 1 << 4)
    static let crankRevolutionDataPresent = CPMFlags(rawValue: 1 << 5)
    static let extremeForceMagnitudesPresent = CPMFlags(rawValue: 1 << 6)
    static let extremeTorqueMagnitudesPresent = CPMFlags(rawValue: 1 << 7)
    static let extremeAnglesPresent = CPMFlags(rawValue: 1 << 8)
    static let topDeadSpotAnglePresent = CPMFlags(rawValue: 1 << 9)
    static let bottomDeadSpotAnglePresent = CPMFlags(rawValue: 1 << 10)
    static let accumulatedEnergyPresent = CPMFlags(rawValue: 1 << 11)
    static let offsetCompensationIndicator = CPMFlags(rawValue: 1 << 12)
}

struct CPMValue {
    public let flags : CPMFlags; // m (16)
    public let instantaneousPower : Int16 // m, Watt
    public let pedalPowerBalance : UInt8 // o, %
    public let accumulatedTorque : UInt16 // o, Nm, 1/32
    public let cumulativeWheelRevolutions : UInt32 // o, 1
    public let lastWheelEventTime : UInt16 // o, s, 1/2048
    public let cumulativeCrankRevolution : UInt16 // o, 1
    public let lastCrankEventTime : UInt16 // o, s, 1/1024
    public let maximumForceMagnitude : Int16 // o, N, 1
    public let minimumForceMagnitude : Int16 // o, N, 1
    public let maximumTorqueMagnitude : Int16 // o, Nm, 1/32
    public let minimumTorqueMagnitude : Int16 // o, Nm, 1/32
    public let maximumAngle : UInt8 // Uint12, o, degree
    public let angleFiller : UInt8 // helper to make struct the desired length
    public let minimumAngle : UInt8 // UInt12, o, degree
    public let topDeadSpotAngle : UInt16 // o, degree
    public let bottomDeadSpotAngle : UInt16 // o, degree
    public let accumulatedEnergy : UInt16 // o, kJ, 1
    // total 34 octetts
}

enum CPMValueOffset : Int {
    case flags = 0 // 16
    case instantaneousPower = 2
    case pedalPowerBalance = 4
    case accumulatedTorque = 5
    case cumulativeWheelRevolutions = 7
    case lastWheelEventTime = 11
    case cumulativeCrankRevolution = 13
    case lastCrankEventTime = 15
    case maximumForceMagnitude = 17
    case minimumForceMagnitude = 19
    case maximumTorqueMagnitude = 21
    case minimumTorqueMagnitude = 23
    case maximumAngle = 25 // 12 bit
    // case minimumAngle = 26.5 // 12 bit
    case topDeadSpotAngle = 28 //16
    case bottomDeadSpotAngle = 30
    case accumulatedEnergy = 32
}

final class CPMCharacteristic : BLECharacteristic {
    
    var flags : CPMFlags = []
    {
        didSet {
            withUnsafeBytes(of: flags.rawValue) {
                self.data.copy(data: Data($0), to: CPMValueOffset.flags.rawValue, size: MemoryLayout<UInt16>.size)
            }
        }
    }
    
    var instantaneousPower : UInt16 = 0
    {
        didSet {
            withUnsafeBytes(of: instantaneousPower) {
                self.data.copy(data: Data($0), to: CPMValueOffset.instantaneousPower.rawValue, size: MemoryLayout<UInt16>.size)
            }
        }
    }
    
    var accumulatedEnergy : UInt16 = 0
    {
        didSet {
            withUnsafeBytes(of: accumulatedEnergy) {
                self.data.copy(data: Data($0), to: CPMValueOffset.accumulatedEnergy.rawValue, size: MemoryLayout<UInt16>.size)
            }
        }
    }
    
    override func updateProperties(_ newData: CharacteristicsData) -> Void {
        self.instantaneousPower = newData.instantaneousPower
        self.accumulatedEnergy = newData.totalEnergy
    
        for observer in observers {
            observer(self.data)
        }
    }
    
    /// init
    override init() {
        super.init()
        
        self.uuid = BluetoothUUID(rawValue: "2A63")!
        self.data = Data(count: 34) // Data(count: MemoryLayout<CPMValue>.size)
        self.properties = [ .notify, .read ]
        self.permissions = [ .read ]
        
        var clientConfiguration = GATTClientCharacteristicConfiguration()
        clientConfiguration.configuration.insert(.notify)
        self.descriptors.append(clientConfiguration.descriptor)
        
        flags = []
        instantaneousPower = 0
        accumulatedEnergy = 0
    }
    
    func description() -> String? {
        return self.data.description
    }
    
}
