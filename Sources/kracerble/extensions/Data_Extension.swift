//
//  BLEUtil.swift
//  Bluetooth
//
//  Created by nebucaz on 29.12.19.
//

import Foundation

extension Data {
    mutating func copy(data: Data, to offset: Int, size: Int) {
        
        // negative size and/or offset is not allowed
        guard size >= 0 && offset >= 0 else {
            return
        }
        
        let srcStart = data.startIndex
        let srcEnd = srcStart + size
        
        let dstStart = self.startIndex + offset
        let dstEnd = dstStart + size
        
        // must not be out of bounds
        guard dstEnd <= self.endIndex else {
            return
        }
        
        self[dstStart..<dstEnd] = data[srcStart..<srcEnd]
    }
    
    // where Seq.Iterator.Element == UInt8
    func hexString(_ separator: String = " ") -> String  {
        let spacesInterval = 8
        var result = ""
        for (index, byte) in self.enumerated() {
  
            if index > 0 && index % spacesInterval == 0 {
                result.append(separator)
            }
            result.append(String(format: "%02x", byte))
        }
        return result
    }
}
