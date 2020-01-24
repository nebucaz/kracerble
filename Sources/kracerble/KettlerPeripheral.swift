//
//  KettlerPeripheral.swift
//  Bluetooth
//
//  Created by nebucaz on 04.01.20.
//

import Foundation
import BluetoothLinux
import GATT

@available(macOS 10.12, *)
class KettlerPeripheral : BLEPeripheral {
    var peripheral: GATTPeripheral<HostController, L2CAPSocket>
    var services: [BLEService] = []
    var characteristicsByHandle: [UInt16 : BLECharacteristic] = [:]
    var servicesByHandle: [UInt16 : BLEService] = [:]
    var advertizedServices : [UInt16] = []
    var name : String = ""
    
    public init(_ hostController: HostController) throws {
        peripheral = try hostController.newPeripheral()
        add(DeviceInformationService(manufacturer: "Kettler Racer 9")) // 0x180A
        add(CyclingPowerService()) // 0x1818
    }
    
    // Start peripheral
    func start() {
        do {
            try peripheral.start()
            
            NSLog("Kettler Peripheral started")
            advertise("KRacer9")
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
