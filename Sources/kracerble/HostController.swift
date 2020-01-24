//
//  HostController.swift
//  Bluetooth
//
//  Created by nebucaz on 04.01.20.
//

import Foundation
import Bluetooth
import GATT
import BluetoothLinux

@available(macOS 10.12, *)
extension HostController {
    public func newPeripheral() throws -> GATTPeripheral<HostController, L2CAPSocket> {
        
        // Setup peripheral
        let address = try readDeviceAddress()
        let serverSocket = try L2CAPSocket.lowEnergyServer(controllerAddress: address, isRandom: false, securityLevel: .low)
        
        let peripheral = GATTPeripheral<HostController, L2CAPSocket>(controller: self)
        peripheral.log = { NSLog("Peripheral Log: \($0)") }
        
        peripheral.newConnection = {
           let socket = try serverSocket.waitForConnection()
           let central = Central(identifier: socket.address)
           NSLog("BLE Peripheral: new connection from \(socket.address)")
           return (socket, central)
        }
        return peripheral
    }
}
