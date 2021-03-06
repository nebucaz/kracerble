//
//  KettlerRacer.swift
//  Bluetooth
//
//  Created by nebucaz on 13.01.20.
//

import Foundation
import SwiftSerial
import Dispatch
import Regex // https://github.com/crossroadlabs/Regex

class KettlerRacer : FitnessDevice {
    static let interval : TimeInterval = TimeInterval(1.0) // seconds
    var maxIdleTime : Int = 60 // 5 minutes, in 5 seconds
    var fitnessSession : FitnessSession? = nil
    var serialPort : SerialPort? = nil
    var connected : Bool
    var timer: RepeatingTimer? // DispatchSourceTimer?
    var delegate : FitnessDeviceDelegate?
    var portName : String?
    var countNoAnswer : Int
    var symbolRate : BaudRate
    var type: KettlerType
    
    init() {
        portName = "/dev/ttyUSB0"
        connected = false
        countNoAnswer = 0
        maxIdleTime = Int(300 / Int(KettlerRacer.interval))
        symbolRate  = .baud57600
        type = .racer9
    }
    
    convenience init(_ portName: String, type: KettlerType = .racer9) {
        self.init()
        self.portName = portName
        self.symbolRate = (type == KettlerType.racer9) ? BaudRate.baud57600 : BaudRate.baud9600
        self.type = type
     }
    
    func startPolling() {
        NSLog("Start polling")
        
        timer = RepeatingTimer(timeInterval: KettlerRacer.interval)
        timer?.eventHandler = {
            
            if self.connected {
               
                let status = self.getStatus()
                let newData = self.parseStatus(status)
                
                guard newData != nil else {
                    NSLog("get status - no data")
                    return
                }
                
                // log in session
                self.logFitnessEvent(newData)
                
                if let delegate = self.delegate {
                    if let data = newData {
                        delegate.didChangeData(data)
                        self.countNoAnswer = 0
                    }
                    else {
                        self.countNoAnswer += 1
                        
                        if self.countNoAnswer > self.maxIdleTime {
                            self.disconnect()
                        }
                    }
                }
            }
            else {
                self.findDevice()
            }
        }
        
        timer?.resume()
    }
    
    func stopPolling() {
        if let timer = self.timer {
            timer.cancel()
        }
        
        timer = nil
        disconnect()
    }
    
    private func disconnect() {
        NSLog("Disconnecting \(self.portName ?? "?")")
        
        self.connected = false
                
        if let serialPort = self.serialPort {
            serialPort.closePort()
            self.serialPort = nil
        }
        
        if let session = fitnessSession {
            session.end()
            
            if let delegate = self.delegate {
                delegate.didEndSession(session)
            }
            NSLog("Closed session \(session.getName())")
        }
    }
    
    deinit {
        self.stopPolling()
    }
    
    func logFitnessEvent(_ data: CharacteristicsData?) {
        if fitnessSession == nil {
            if let delegate = self.delegate {
                delegate.willStartSession()
            }
            
            fitnessSession = FitnessSession()
            
            if let session = fitnessSession {
                session.start()
                NSLog("Created fitness session \(session.getName())")
                
                if let delegate = self.delegate {
                    delegate.didStartSession(session)
                }
            }
        }
        
        if let session = fitnessSession {
            session.append(data)
        }
    }
    
    // Protocol: https://technomathematik.blogspot.com/2013/10/ergometer-kettler-fx1-serial-protocol.html
    func parseStatus(_ status: String?) -> CharacteristicsData? {
        guard let status = status else {
            return nil
        }
        
        var newData = CharacteristicsData()
        
        if self.type == .racer9 {
            _ = matchRacer(status, newData: &newData)
        }
        else {
           matchTreadmill(status, newData: &newData)
        }
        
        return newData
    }
    
    func matchRacer(_ status: String, newData: inout CharacteristicsData ) -> Bool {
        let statusPattern = "(\\d+)\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)\\s+(\\d{1,2}):(\\d{2})\\s+(\\d+)"
        
        do {
            let regex: Regex = try Regex(pattern: statusPattern,
                                         groupNames:"pulse", "rpm", "speed", "dist", "reqpower", "energy", "min", "sec", "power")
            
            let match = regex.findFirst(in: status)
            if let match = match {
                if let rpm = match.group(named: "rpm") {
                    newData.instantaneousCadence = UInt16(rpm)!
                }
                
                if let instantaneousPower = match.group(named: "power") {
                    newData.instantaneousPower = UInt16(instantaneousPower)!
                }
                
                if let energy = match.group(named: "energy") {
                    newData.totalEnergy = UInt16(energy)!
                }
                
                if let speed = match.group(named: "speed") {
                    newData.instantaneousSpeed = UInt16(speed)!
                }
                
                if let dist = match.group(named: "dist") {
                    newData.totalDistance = UInt32(dist)! * 100
                }
                
                if let time = match.group(named: "min") {
                    newData.elapsedTime = UInt16(time)! * 60
                }
                
                if let sec = match.group(named: "sec") {
                    newData.elapsedTime += UInt16(sec)!
                }
                
                if let pulse = match.group(named: "pulse") {
                    newData.heartRate = UInt8(pulse)!
                }
                
                return true
            }
            else {
                NSLog("RegEx: Can not match racer status \(status)")
            }
        } catch let error {
            NSLog("RegEx: parseStatus error \(error)")
        }
        
        return false
    }
    
    // treadmill = - ST = 000 -> 000 -> 0000 -> 00 -> 0000 -> 00:00 -> 000 -> 00   x0d, 0x0a
    // 1. Heart Rate, 2. Speed (km/h * 10), 3. Distance (m *10), 4. Inclination (%), 5. Energy (Ws), 6. Time (mm:ss), 7. Speed (km/h * 10), 8. Inclination (%)
    //
    func matchTreadmill(_ status : String, newData: inout CharacteristicsData ) {

        let statusPattern = "(\\d+)\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)\\s+(\\d+):(\\d{2})\\s+(\\d+)"
                               

        do {
            let regex: Regex = try Regex(pattern: statusPattern,
                                         groupNames:"pulse", "speed", "dist", "incl", "energy", "min", "sec", "speed2", "incl2")
            
            let match = regex.findFirst(in: status)
            if let match = match {
                if let incl = match.group(named: "incl") {
                    newData.inclination = Int16(incl)! * 10
                }
                
                if let energy = match.group(named: "energy") {
                    newData.totalEnergyWs = UInt16(energy)!
                }
                
                // a value of 2560 correspondes to 36 km/h, 256 = 3.6 km/h = 1m/s
                if let speed = match.group(named: "speed") {
                    let speed256 = (UInt16(speed)! * 256) / 36
                    newData.instantaneousSpeed = UInt16(speed256)
                }
                
                if let dist = match.group(named: "dist") {
                    newData.totalDistance = UInt32(dist)! * 100
                }
                
                if let time = match.group(named: "min") {
                    newData.elapsedTime = UInt16(time)! * 60
                }
                
                if let sec = match.group(named: "sec") {
                    newData.elapsedTime += UInt16(sec)!
                }
                
                if let pulse = match.group(named: "pulse") {
                    newData.heartRate = UInt8(pulse)!
                }
                
            }
            else {
                NSLog("RegEx: Can not match track s5 status \(status)")
            }
        } catch let error {
            NSLog("RegEx: parseStatus error \(error)")
        }
    }
    
    // scans serial Ports for Kettler
    func findDevice() {
        disconnect()

        let path = "/dev/ttyUSB"
        
        var i : Int = 0
        while i < 4 {
            self.portName = path + String(i)
            
            if let portName = self.portName {
                serialPort = SerialPort(path: portName)
                
                do {
                    try serialPort?.openPort()
                    NSLog("Serial port \(portName) opened successfully.")
                    
                    serialPort?.setSettings(receiveRate: self.symbolRate, // .baud57600,
                                            transmitRate: self.symbolRate, // .baud57600,
                                            minimumBytesToRead: 0,
                                            timeout: 0,
                                            dataBitsSize: .bits8)

                   // let id = self.getID()
                    if let id = self.getID() {
                        if id.lengthOfBytes(using: .ascii) <= 0 {
                            NSLog("empty ID")
                            continue
                        }
                    }
                    
                    if let ve = self.getVersion() {
                        if ve.lengthOfBytes(using: .ascii) <= 0  {
                            NSLog("empty version")
                            continue
                        }
                    }
                    
                    countNoAnswer = 0
                    connected = true
                    break
                } catch PortError.deviceNotConnected {
                    NSLog("Device not connected, on \(portName). Try next port")
                } catch PortError.failedToOpen {
                    NSLog("Serial port \(portName) failed to open. You might need root permissions.")
                } catch {
                    NSLog("connect error: \(error.localizedDescription)")
                }
            }
            
            i += 1
        }
    }
    
    func command(_ cmd : String) -> String? {
        var stringReceived : String?
        
        do {
            _ = try serialPort?.writeString("\(cmd.utf8)\r\n")

            stringReceived = try serialPort?.readUntilChar(0x0d)
            
            /*
            let rcvData = try serialPort?.readData(ofLength: 80)
            if let data = rcvData {
                if data.count >= 1 {
                    stringReceived = String(bytes: data, encoding: .ascii)
                }
            }
            */
        } catch PortError.deviceNotConnected {
            NSLog("Device not connected. Trying to reconnect")
            findDevice()
        } catch {
            NSLog("CMD error: \(error.localizedDescription)")
        }
        return stringReceived
    }
    
    func getID() -> String? {
        return command("ID")
    }
    
    func getVersion() -> String? {
        return command("VE")
    }
    
    func getStatus()  -> String? {
        return command("ST")
    }
    
    func setPower(_ requestedPower: Int) -> String? {
        return command(String(format: "CM\r\n PP %03d\r\n", requestedPower))
    }
    
    func setDistance() -> String? {
        return "sad"
    }
    
    func setTime() -> String? {
        return "sad"
    }
    
    func canWrite() -> Bool {
        do {
            let writeResult = try serialPort?.writeData(Data([0x0a, 0x0d]))
            return (writeResult! >= 1) ? true : false
        } catch {
            NSLog("Error: \(error.localizedDescription)")
        }
        
        return false
    }
    
    func tryReading() -> Bool {
    
        do {
            let lenght = try serialPort?.writeData(Data([0x56,0x45]))
            if lenght! >= 1 {
                let data = try serialPort?.readData(ofLength: 1)
                return (data!.count >= 1) ? true : false
            }
            else {
                NSLog("Can not read")
            }
        }
        catch let error {
            NSLog ("Error reading \(error.localizedDescription)")
        }
        
        return false
    }
}
