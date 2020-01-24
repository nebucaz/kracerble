//
//  FitnessDevice.swift
//  Bluetooth
//
//  Created by nebucaz on 16.01.20.
//

import Foundation

protocol FitnessDeviceDelegate {
    func willStartSession()
    func didStartSession(_ session:FitnessSession)
    func didEndSession(_ session:FitnessSession)
    func didChangeData(_ newData : CharacteristicsData)
}

protocol FitnessDevice {
    func startPolling()
    func stopPolling()
    func command(_ cmd : String) -> String?
}
