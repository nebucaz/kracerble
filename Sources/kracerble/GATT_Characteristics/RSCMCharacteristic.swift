//
//  File.swift
//  
//
//  Created by neo on 30.11.20.
//

import Foundation
import Bluetooth
import GATT

/*
 The RSC Measurement characteristic (RSC refers to
     Running Speed and Cadence) is a variable length structure
     containing a Flags field, an Instantaneous Speed field and an
     Instantaneous Cadence field and, based on the contents of the
     Flags field, may contain a Stride Length field and a Total
     Distance field.
 */
struct RSCMFlags : OptionSet {
    let rawValue: UInt8
    
    static let instantaneousStrideLengthPresent = RSCMFlags(rawValue: 1 << 0)
    static let totalDistancePresent = RSCMFlags(rawValue: 1 << 1)
    static let walkingOrRunningStatusBits = RSCMFlags(rawValue: 1 << 2)
}

struct RSCMValue {
    public let flags : RSCMFlags; // m (8)
    
    /// Unit is in m/s with a resolution of 1/256
    public let instantaneousSpeed : UInt16
    
    /// Unit is in 1/minute (or RPM) with a resolutions of 1 1/min (or 1 RPM)
    public let instantaneousCadence : UInt8
    
    // Unit is in meter with a resolution of 1/100 m (or centimeter)
    public let instantaneousStrideLength : UInt16
    
    /// Unit is in meter with a resolution of 1/10 m (or decimeter)
    public let totalDistance : UInt32
}

enum RSCMValueOffset : Int {
    case flags = 0 // 8
    case instantaneousSpeed = 1
    case instantaneousCadence = 3
    case instantaneousStrideLength = 4
    case totalDistance = 6
}

final class RSCMCharacteristic : BLECharacteristic {
    var flags : RSCMFlags = []
    {
        didSet {
            withUnsafeBytes(of: flags.rawValue) {
                self.data.copy(data: Data($0), to: RSCMValueOffset.flags.rawValue, size: MemoryLayout<UInt8>.size)
            }
        }
    }
    
    var instantaneousSpeed : UInt16 = 0
    {
        didSet {
            withUnsafeBytes(of: instantaneousSpeed) {
                self.data.copy(data: Data($0), to: RSCMValueOffset.instantaneousSpeed.rawValue, size: MemoryLayout<UInt16>.size)
            }
        }
    }
    
    var totalDistance : UInt32 = 0
    {
        didSet {
            withUnsafeBytes(of: totalDistance) {
                self.data.copy(data: Data($0), to: RSCMValueOffset.totalDistance.rawValue, size: MemoryLayout<UInt32>.size)
            }
        }
    }
    
    override func updateProperties(_ newData: CharacteristicsData) -> Void {
        self.instantaneousSpeed = newData.instantaneousSpeed
        self.totalDistance = newData.totalDistance
    
        for observer in observers {
            observer(self.data)
        }
    }
    
    /// init
    override init() {
        super.init()
        
        self.uuid = BluetoothUUID(rawValue: "2A53")!
        self.data = Data(count: MemoryLayout<RSCMValue>.size) // 10
        self.properties = [ .notify, .read ]
        self.permissions = [ .read ]
        
        var clientConfiguration = GATTClientCharacteristicConfiguration()
        clientConfiguration.configuration.insert(.notify)
        self.descriptors.append(clientConfiguration.descriptor)
        
        flags = []
        instantaneousSpeed = 0
        totalDistance = 0
    }
    
    func description() -> String? {
        return self.data.description
    }
}
