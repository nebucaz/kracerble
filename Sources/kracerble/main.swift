    
import Foundation

let machineType : KettlerType = .track5 // .racer9
var portName = "/dev/ttyUSB0"
let arguments = CommandLine.arguments
if arguments.count >= 2 {
    portName = arguments[1]
}

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
 
 
/*
var portName = "/dev/ttyUSB0"
var type : KettlerType = .racer9

// sudo Swish/kracerble/.build/debug/kracerble [type] [port] > /dev/null 2>&1 &
let arguments = CommandLine.arguments
if arguments.count >= 2 {
    portName = arguments[2]
}

*/
