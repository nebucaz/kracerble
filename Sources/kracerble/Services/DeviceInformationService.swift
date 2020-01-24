//
//  DeviceInformationService.swift
//  Bluetooth
//
//  Created by nebucaz on 05.01.20.
//

import Foundation
import Bluetooth

final class StringCharacteristic : BLECharacteristic {
    init(uuid: BluetoothUUID, rawValue: String) {
       super.init()
        
        self.uuid = uuid
        self.data = Data(rawValue.utf8)
    }
}

class DeviceInformationService : BLEService {
    var uuid: BluetoothUUID
    var characteristics : [BLECharacteristic] = []
    
    init(manufacturer: String) {
        self.uuid = .deviceInformation
        
        self.characteristics.append(StringCharacteristic(uuid: .manufacturerNameString , rawValue: manufacturer))
        
        // manufacturer_name_string, optional
        // model_number_string, optional
        // serial_number_string, optional
        // hardware_revision_string, optional
        // firmware_revision_string, optional
        // software_revision_string, optional
        
        /// This characteristic represents a structure containing an Organizationally Unique Identifier (OUI) followed by a manufacturer-defined identifier and is unique for each individual instance of the product.
        // characteristic.system_id, optional
        // ieee_11073-20601_regulatory_certification_data_list, optional
        // pnp_id, optional
    }
}

