//
//  BLECharacteristic.swift
//  Bluetooth
//
//  Created by nebucaz on 29.12.19.
//

import Foundation
import Bluetooth
import GATT

protocol BLECharactetristicType {
    var uuid: BluetoothUUID { get }
    var properties: BitMaskOptionSet<GATT.Characteristic.Property> { get }
    var permissions: BitMaskOptionSet<GATT.Permission> { get }
    var descriptors: [GATT.Characteristic.Descriptor] { get }
    var data: Data { get set }

    func didSet(_ observer: @escaping (Data) -> Void)
    func updateProperties(_ newData: CharacteristicsData) -> Void
}

public class BLECharacteristic : BLECharactetristicType {

    public var uuid: BluetoothUUID = BluetoothUUID(data: Data(bytes: [0x00,0x00], count: 2))!
    
    public var properties: BitMaskOptionSet<GATT.Characteristic.Property> = [] {
        didSet(property) {
            self.descriptors = (property.contains(.notify) ? [GATTClientCharacteristicConfiguration().descriptor] : [])
        }
    }
    
    public var permissions: BitMaskOptionSet<GATT.Permission> = []
    public var descriptors: [GATT.Characteristic.Descriptor]
    public var data : Data

    internal var observers: [(Data) -> Void] = []
    
    public func didSet(_ observer: @escaping (Data) -> Void) {
        observers += [{ observer($0) }]
    }
    
    public func didSet(_ observer: @escaping () -> Void) {
        observers += [{ _ in observer() }]
    }
    
    func updateProperties(_ newData: CharacteristicsData) -> Void {}
    
    public init() {
        self.properties = [.read, .notify]
        self.permissions = [.read ] // properties.inferredPermissions
        
        // we need this special descriptor to enable notifications!
        self.descriptors = []
        self.data = Data()
    }
    
    func copyToData(_ value: UInt8, offset: Int) {
        withUnsafeBytes(of: value) {
            self.data.copy(data: Data($0), to: offset, size: MemoryLayout<UInt8>.size)
        }
    }
    
    func copyToData(_ value: UInt16, offset: Int) {
        withUnsafeBytes(of: value) {
            self.data.copy(data: Data($0), to: offset, size: MemoryLayout<UInt16>.size)
        }
    }
    
    func copyToData(_ value: Int16, offset: Int) {
        withUnsafeBytes(of: value) {
            self.data.copy(data: Data($0), to: offset, size: MemoryLayout<Int16>.size)
        }
    }
    
    func copyToData(_ value: UInt32, offset: Int) {
        withUnsafeBytes(of: value) {
            self.data.copy(data: Data($0), to: offset, size: MemoryLayout<UInt32>.size)
        }
    }
}

extension BitMaskOptionSet where Element == GATT.Characteristic.Property {
    var inferredPermissions: BitMaskOptionSet<GATT.Permission> {
        let mapping: [GATT.Characteristic.Property: ATTAttributePermission] = [
            .read: .read,
            .notify: .read,
            .write: .write
        ]
        
        var permissions = BitMaskOptionSet<GATT.Permission>()
        for (property, permission) in mapping {
            if contains(property) {
                permissions.insert(permission)
            }
        }
        return permissions
    }
}
