//
//  CyclingPowerService.swift
//  Bluetooth
//
//  Created by nebucaz on 03.01.20.
//

import Foundation
import Bluetooth

class CyclingPowerService : BLEService {
    var uuid: BluetoothUUID
    var characteristics : [BLECharacteristic] = []
    
    // 0x1818
    init() {
        
        // M: 0x2A63, org.bluetooth.characteristic.cycling_power_measurement
        self.uuid = .cyclingPower
        let cpm = CPMCharacteristic()
        cpm.flags = [] // .accumulatedEnergyPresent
        self.characteristics.append(cpm)
        
        // M: 0x2A65, org.bluetooth.characteristic.cycling_power_feature
        let cpf = CPFCharacteristic()
        cpf.flags = [] // .accumulatedEnergySupported
        self.characteristics.append(cpf)
        
        // M: 0x2A5D, org.bluetooth.characteristic.sensor_location
        let sloc = BLESensorLocation()
        sloc.sensorLocation = .rearWheel
        self.characteristics.append(sloc)
        
        // O: 0x2A64, org.bluetooth.characteristic.cycling_power_vector
        // O: 0x2A66, org.bluetooth.characteristic.cycling_power_control_point
    }
}
