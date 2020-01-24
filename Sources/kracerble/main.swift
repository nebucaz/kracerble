
// import Glibc
// import SwiftSerial

import Foundation

var portName = "/dev/ttyUSB0"
let arguments = CommandLine.arguments
if arguments.count >= 2 {
    portName = arguments[1]
}

if #available(macOS 10.12, *) {
    var kettler : KettlerProxy?
    
    do {
        kettler = KettlerProxy()
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
    exit(0)
}
else
{
    exit(-1)
}
