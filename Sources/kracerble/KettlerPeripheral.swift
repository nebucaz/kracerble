//
//  KettlerPeripheral.swift
//  Bluetooth
//
//  Created by nebucaz on 04.01.20.
//

import Foundation
import Bluetooth
import BluetoothLinux
import GATT

enum KettlerType : UInt8 {
    case racer9 = 0
    case track5
}

@available(macOS 10.12, *)
class KettlerPeripheral : BLEPeripheral {
    var peripheral: GATTPeripheral<HostController, L2CAPSocket>
    var services: [BLEService] = []
    var characteristicsByHandle: [UInt16 : BLECharacteristic] = [:]
    var servicesByHandle: [UInt16 : BLEService] = [:]
    var advertizedServices : [UInt16] = []
    var name : String = ""
    
    public init(_ hostController: HostController, type: KettlerType = .racer9) throws {
        peripheral = try hostController.newPeripheral()
        
        switch (type) {
        case .racer9:
            add(DeviceInformationService(manufacturer: "Kettler Racer 9")) // 0x180A
            add(CyclingPowerService()) // 0x1818
            name = "KRacer9"
        case .track5:
            add(DeviceInformationService(manufacturer: "Kettler Track 5")) // 0x180A
            add(RunningSpeedCadenceService()) // 0x1814
            name = "KTrack5"
        }
        
        if type == .racer9 {
            NSLog("Peripheral type is Cycling Power")
        } else {
            NSLog("Running Speed and Cadence")
        }
    }
    
    // Start peripheral
    func start() {
        do {
            try peripheral.start()
            NSLog("Kettler Peripheral started")
 
            let localName = GAPCompleteLocalName(name: name)
            advertise(localName)
        }
        catch let error {
            NSLog("Can not start peripheral \(error.localizedDescription)")
        }
    }
    
    func didChangeData(_ newData: CharacteristicsData) {
        for (_, characteristic) in characteristicsByHandle {
            characteristic.updateProperties(newData)
        }
    }
}
