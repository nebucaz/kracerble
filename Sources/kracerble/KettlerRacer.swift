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

    init() {
        portName = "/dev/ttyUSB0"
        connected = false
        countNoAnswer = 0
        maxIdleTime = Int(300 / Int(KettlerRacer.interval))
    }
    
    convenience init(_ portName: String) {
        self.init()
        self.portName = portName
    }
    
    func startPolling() {
        timer = RepeatingTimer(timeInterval: KettlerRacer.interval)
        timer?.eventHandler = {
            
            if self.connected {
                let status = self.getStatus()
                let newData = self.parseStatus(status)
                
                guard newData != nil else {
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
                
            }
            else {
                NSLog("RegEx: Can not match status \(status)")
            }
        } catch let error {
            NSLog("RegEx: parseStatus error \(error)")
        }
        
        return newData
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
                    
                    serialPort?.setSettings(receiveRate: .baud57600,
                                            transmitRate: .baud57600,
                                            minimumBytesToRead: 0,
                                            timeout: 0)

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
            _ = try serialPort?.writeString("\(cmd)\r\n")
            
            let rcvData = try serialPort?.readData(ofLength: 80)
            if let data = rcvData {
                if data.count >= 1 {
                    stringReceived = String(bytes: data, encoding: .ascii)
                }
            }
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
            let writeResult = try serialPort?.writeData(Data([0x10, 0x13]))
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
