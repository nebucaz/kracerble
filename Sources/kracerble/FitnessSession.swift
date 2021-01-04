//
//  FitnessSession.swift
//  Bluetooth
//
//  Created by nebucaz on 18.01.20.
//

import Foundation

class FitnessSession {
    var path : String
    var fileName : String
    var fileHandle : FileHandle?
    
    init() {
        path = "/home/pi/kettler/"
        fileName = "unknown"
        
    }
    
    init (withPath: String) {
        path = withPath
        fileName = "unknown"
    }
    
    func start() {
        let header : String = "Power,Energy,Speed,Duration,Distance,rpm,bpm,Requested Power\n"
        
        fileName = makeFileName()
        let fullPath : String = self.path.appending(fileName)
        
        let manager = FileManager.init()
        if manager.createFile(atPath: fullPath,
                                   contents: nil, attributes: nil) {
            fileHandle = FileHandle(forWritingAtPath: fullPath)
            
            if let fh = fileHandle {
                fh.write(header.data(using: .utf8)!)
            }
        }
        else {
            NSLog("error creating file")
        }
    }
    
    // end session, close file
    func end() {
        if let fh = fileHandle {
            fh.synchronizeFile()
            fh.closeFile()
        }
    }
    
    // append a new Line
    func append(_ newData: CharacteristicsData?) {
        guard let data = newData else {
            return
        }
        
        let line : String = String(format: "\(data.instantaneousPower),\(data.totalEnergy),\(data.instantaneousSpeed),\(data.elapsedTime),\(data.totalDistance),\(data.instantaneousCadence),\(data.heartRate),\(data.requestedPower)\n")
        
        if let fh = fileHandle {
            fh.write(line.data(using: .utf8)!)
        }
    }
    
    func makeFileName() -> String {
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "de_CH_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd_HHmm"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 3600)
        
        var name : String = "kettler_"
        name.append(RFC3339DateFormatter.string(from:Date()))
        name.append(".csv")
        return name
    }
    
    func getName() -> String {
        return fileName
    }
}
