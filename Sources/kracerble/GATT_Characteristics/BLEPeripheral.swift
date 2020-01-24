//
//  BLEPeripheral.swift
//  Bluetooth
//
//  Created by nebucaz on 03.01.20.
//

import Foundation
import Bluetooth
import GATT
import BluetoothLinux

@available(macOS 10.12, *)

protocol BLEPeripheral : class {
    func start()
    
    var peripheral: GATTPeripheral<HostController, L2CAPSocket> { get }
    var services: [BLEService] { get set }
    var characteristicsByHandle: [UInt16: BLECharacteristic] { get set }
    var servicesByHandle : [UInt16 : BLEService] { get set }
    var advertizedServices : [UInt16] { set get }
    var name : String { get set }
}

@available(macOS 10.12, *)
extension BLEPeripheral {
    
    func add(_ service: BLEService) {
        
        let characteristics : [BLECharacteristic] = service.characteristics
        
        let gattCharacteristics = service.characteristics.map {
            GATT.Characteristic(uuid: $0.uuid, value: $0.data, permissions: $0.permissions, properties: $0.properties, descriptors: $0.descriptors)
        }
        
        let gattService = GATT.Service(uuid: service.uuid, primary: true, characteristics: gattCharacteristics)
        
        do {
            let serviceHandle = try peripheral.add(service: gattService)
            servicesByHandle[serviceHandle] = service
            //NSLog("added service \(service.uuid.toUint16()) by handle \(serviceHandle)")
            
            for characteristic in characteristics {
                guard let handle = peripheral.characteristics(for: characteristic.uuid).last else { continue }
                
                NSLog("Characteristic \(characteristic.uuid) with permissions \(characteristic.permissions) and \(characteristic.descriptors.count) descriptors")
                
                // Register as observer for each characteristic
                characteristic.didSet { [weak self] in
                    NSLog("Service \(service.uuid): characteristic \(characteristic.uuid) did change with new value \($0)")
                    self?.peripheral[characteristic: handle] = $0
                }
                
                characteristicsByHandle[handle] = characteristic
            }
            
            //services += [service]
            // wozu brauche ich das?
            services.append(service)
            self.advertizedServices.append(service.uuid.toUint16())
        }
        catch let error {
            NSLog ("Peripheral: Error adding service \(error.localizedDescription)")
        }
    }
    
    // Advertise services and peripheral name
    public func advertise(_ name: GAPCompleteLocalName)   {
        
        
        self.name = name.name
        var services = ""
        for element in self.advertizedServices {
            services += String(format:"0x%02X ", element)
        }
        
        let serviceUUIDs : GAPCompleteListOf16BitServiceClassUUIDs = GAPCompleteListOf16BitServiceClassUUIDs(uuids: self.advertizedServices)
        let encoder = GAPDataEncoder()
        do {
            let data = try encoder.encodeAdvertisingData(name, serviceUUIDs)
            try peripheral.controller.setLowEnergyScanResponse(data, timeout: .default)
            NSLog("advertizing services \(services)")
            
            // Setup iBeacon
            /*
             let iBeaconUUID = UUID(rawValue: "1DC24957-9DDA-46C4-88D4-3D3640CB3FDA")
             if let iBeaconUUID = iBeaconUUID {
             let rssi: Int8 = 30
             let beacon = AppleBeacon(uuid: iBeaconUUID, rssi: rssi)
             let flags: GAPFlags = [.lowEnergyGeneralDiscoverableMode, .notSupportedBREDR]
             try peripheral.controller.iBeacon(beacon, flags: flags, interval: .min, timeout: .default)
             }
             */
        } catch let error {
            NSLog("Peripheral: Error encodeAdvertisingData \(error.localizedDescription)")
        }
    }
    
    func shutdown() {
        NSLog("Shutting down peripheral \(self.name)")
        
        for (serviceHandle, _) in servicesByHandle {
            peripheral.remove(service: serviceHandle)
        }
        
        peripheral.stop();
    }
}
