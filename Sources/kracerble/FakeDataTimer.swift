//
//  FakeDataTimer.swift
//  Bluetooth
//
//  Created by nebucaz on 03.01.20.
//
// https://stackoverflow.com/questions/47394725/swift-timer-in-linux

import Foundation
import Dispatch

class FakeDataTimer {
    static let interval : Double = 2.0
    var data : CharacteristicsData
    var timer: DispatchSourceTimer?
    var delegate : FitnessDeviceDelegate?
    
    init() {
        self.data = CharacteristicsData()
    }
    
    convenience init(delegate: FitnessDeviceDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    func start() {
        let queue = DispatchQueue(label: "com.domain.fakedata.timer")
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: FakeDataTimer.interval, leeway: .seconds(0))
        timer?.setEventHandler { [weak self] in
            self?.timerAction()
        }
        timer?.resume()
    }
    
    func timerAction() {
        self.data.instantaneousPower = UInt16.random(in: 80...120)
        self.data.totalEnergy += UInt16.random(in: 1...10)
        self.data.instantaneousSpeed = UInt16.random(in: 11...22)
        self.data.totalDistance += UInt32.random(in: 5...10)
        self.data.elapsedTime += UInt16(exactly: FakeDataTimer.interval)!
        self.data.instantaneousCadence = UInt16.random(in: 200...300)
        self.data.heartRate = UInt8.random(in: 70...180)
        self.data.inclination = Int16.random(in: 0...12)
        self.data.totalEnergyWs = UInt16.random(in: 0...500)
        
        if let delegate = delegate {
            delegate.didChangeData(self.data)
        }
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
    }
    
    deinit {
        self.stop()
    }
}
