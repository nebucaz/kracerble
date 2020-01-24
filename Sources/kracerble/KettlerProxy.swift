//
//  KettlerProxy.swift
//  Bluetooth
//
//  Created by nebucaz on 04.01.20.
//

import Foundation
import Bluetooth
import BluetoothLinux

@available(macOS 10.12, *)
class KettlerProxy : FitnessDeviceDelegate {
    
    var peripheral : KettlerPeripheral?
    var racer : KettlerRacer?
    var timer : FakeDataTimer?
    
    enum Error : Swift.Error {
        case bluetoothUnavailable
    }
    
    func startPolling(_ portName : String = "/dev/ttyUSB0") {
        
        guard peripheral != nil else {
            NSLog("missing peripheral - do you have access to bluetooth (maybe must be root)")
            return
        }
        
        racer = KettlerRacer(portName)
        racer?.delegate = self
        racer?.startPolling()
    }
    
    func startBluetooth() throws {
        guard let hostController = HostController.default else {
            throw Error.bluetoothUnavailable
        }
        
        do {
            peripheral = try KettlerPeripheral(hostController)
            peripheral?.start()
            NSLog("start")
        }
        catch let error{
            NSLog(error.localizedDescription)
        }
    }
    
    func shutdown() {
         NSLog("sutdown")
        if let timer = timer {
            timer.stop()
        }
        
        if let racer = racer {
            racer.stopPolling();
        }
        
        if let peripheral = peripheral {
            peripheral.shutdown()
        }
    }
    
    func provideFakeData() {
        timer = FakeDataTimer(delegate: self)
        if let timer = timer {
            timer.start()
        }
    }
    
    // MARK FitnessDevice Delegate
    
    func willStartSession() {
        NSLog("will Start Session")
    }
    
    func didStartSession(_ session:FitnessSession) {
        
    }
    
    func didEndSession(_ session:FitnessSession) {
        NSLog("Did End Sessoin")
    }
    
     func didChangeData(_ newData: CharacteristicsData) {
        peripheral?.didChangeData(newData)
    }
}
