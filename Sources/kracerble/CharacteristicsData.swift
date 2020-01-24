//
//  CharacteristicsData.swift
//  Bluetooth
//
//  Created by nebucaz on 04.01.20.
//

import Foundation

struct CharacteristicsData {
    /// Watts with a resolution of 1
    var instantaneousPower : UInt16 = 0
    
    /// Watts with a resolution of 1
    var averagePower : Int16 = 0
    
    /// Kilo Calorie with a resolution of 1
    var totalEnergy : UInt16 = 0
    
    /// 1/minute with a resolution of 0.5
    var averageCadence : UInt16 = 0
    
    /// Kilometer per hour with a resolution of 0.01
    var instantaneousSpeed : UInt16 = 0
    
    /// Kilometer per hour with a resolution of 0.01
    var averageSpeed : UInt16 = 0
    
    /// Meters with a resolution of 1
    var totalDistance : UInt32 = 0 // UInt24
    
    var requestedPower : UInt16 = 0
    
    /// Second with a resolution of 1
    var elapsedTime : UInt16  = 0
    
    /// Second with a resolution of 1
    var remainingTime : UInt16 = 0
    
    /// 1/minute with a resolution of 0.5
    var instantaneousCadence : UInt16 = 0
    
    /// Beats per minute with a resolution of 1
    var heartRate : UInt8 = 0
    
    /*
     /// 1/minute with a resolution of 0.5
     var averageCadence : UInt16
     
     /// Unitless with a resolution of 1
     var resistanceLevel : Int16
     
     /// Watts with a resolution of 1
     var instantaneousPower : Int16
     
     /// Watts with a resolution of 1
     var averagePower : Int16
     
     /// Kilo Calorie with a resolution of 1
     var totalEnergy : UInt16
     
     /// Kilo Calorie with a resolution of 1
     var energyPeHour : UInt16
     
     /// Kilo Calorie with a resolution of 1
     var energyPerMinute : UInt8
     

     
     /// Metabolic Equivalent with a resolution of 0.1
     var metabolicEquivalent : UInt8
     */
    
}
