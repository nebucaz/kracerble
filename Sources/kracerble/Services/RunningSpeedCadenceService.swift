//
//  File.swift
//  
//
//  Created by neo on 30.11.20.
//

import Foundation
import Bluetooth

// Running Speed and Cadence

/*
 The Running Speed and Cadence (RSC) Service exposes
     speed, cadence and other data related to fitness applications
     such as the stride length and the total distance the user has
     traveled while using the Speed and Cadence Sensor
 */

class RunningSpeedCadenceService : BLEService {
    var uuid: BluetoothUUID
    var characteristics : [BLECharacteristic] = []
    
    // 0x1814
    init() {
        self.uuid = .runningSpeedAndCadence
        
        // M: 0x2A53, org.bluetooth.characteristic.rsc_measurement
        let rscm = RSCMCharacteristic()
        rscm.flags = [.totalDistancePresent]
        self.characteristics.append(rscm)
        
        // M: 0x2A54, org.bluetooth.characteristic.rsc_feature
        let rscf = RSCFCharacteristic()
        rscf.flags = [.totalDistanceMeasurementSupported] 
        self.characteristics.append(rscf)
    }
}
