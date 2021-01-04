//
//  main.swift
//  kracerble
//
//  Created by neo on 22.01.20.
//  Copyright © 2020 page.agent. All rights reserved.
//

import Foundation

var machineType : KettlerType = .racer9
var portName = "/dev/ttyUSB0"

// #TODO: better arguments - ArgumentParser
let arguments = CommandLine.arguments
if arguments.count >= 2 {
    portName = arguments[1]
}
    
if arguments.count >= 3 {
    machineType = .track5 //
    NSLog("Machine type set to track s5")
}
else {
    NSLog("Machine type= racer 9")
}
    
if #available(macOS 10.12, *) {
    var kettler : KettlerProxy?
    
    do {
        kettler = KettlerProxy(machineType)
        try kettler?.startBluetooth()
        
        //kettler?.provideFakeData()
        kettler?.startPolling(portName)
    } catch let error {
        NSLog("Error initializing BLE peripheral: \(error.localizedDescription)")
    }
    
    // main loop
    while true {
        sleep(10)
        //if readLine() != nil {
        //    break
        // }
    }
    
    // must be called in sigterm handler instead
    if let kettler = kettler {
        kettler.shutdown()
    }
    
    NSLog("Exit Peripheral")
    //exit(0)
}

/*
import ArgumentParser // needs Swift 5.3 ?

struct KRacerBLE: ParsableCommand {
    @Option(help: "The serial port to be used")
    var port: String?

    @Flag(help: "Include a counter with each repetition.")
    var treadmill = false

    @Argument(help: "The phrase to repeat.")
    var phrase: String

    mutating func run() throws {
        let portName = port ?? "/dev/ttyUSB0"
        let machineType : KettlerType = treadmill ? .track5 : .racer9

        if #available(macOS 10.12, *) {
            var kettler : KettlerProxy?
            
            do {
                kettler = KettlerProxy()
                try kettler?.startBluetooth(machineType)
                
                //kettler?.provideFakeData()
                kettler?.startPolling(portName)
            } catch let error {
                NSLog("Error initializing BLE peripheral: \(error.localizedDescription)")
            }
            
            // main loop
            while true {
                sleep(10)
                //if readLine() != nil {
                //    break
                // }
            }
            
            // must be called in sigterm handler instead
            if let kettler = kettler {
                kettler.shutdown()
            }
            
            NSLog("Exit Peripheral")
            //exit(0)
        }
    }
}

KRacerBLE.main()
*/
