//
//  StaticFunctions.swift
//  Schnitzeljagd
//
//  Created by Stefanie Kloss on 22.06.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import CoreLocation
import SwiftUI

final class StaticFunctions {
    
    static func formatTime(seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: TimeInterval(seconds))!
    }
    
    static func calculateRandomCenter(latitude: CLLocationDegrees, longitude: CLLocationDegrees, maxOffsetInMeters: Int) -> (latitude: Double, longitude: Double){

        let earthRadius: Double = 6378137
        
        let maxOffset = maxOffsetInMeters - Int(NumberEnum.offsetBuffer.rawValue)
        var xOffset: Int
        var yOffset: Int
        repeat {
            xOffset = Int.random(in: 0...maxOffset*2) - maxOffset
            yOffset = Int.random(in: 0...maxOffset*2) - maxOffset
        } while Double(maxOffset) < Double(xOffset*xOffset + yOffset*yOffset).squareRoot()

        let latitudeOffset: Double = Double(xOffset)/earthRadius
        let longitudeOffset: Double = Double(yOffset)/(earthRadius * cos(Double.pi * latitude/180.0))
      
        let latitudeResult: Double = latitude + latitudeOffset * 180.0/Double.pi
        let longitudeResult: Double = longitude + longitudeOffset * 180.0/Double.pi
        
        return (latitude: latitudeResult, longitude: longitudeResult)
    }
    
    static func getBackgroundColor(distanceToSchnitzel: Double?) -> Color {
              switch DataModel.shared.screenState{
              case .SEARCH_SCHNITZEL_MAP, .SEARCH_SCHNITZEL_AR:
                        if distanceToSchnitzel == nil {
                                  return Color(red: 0.18, green: 0.52, blue: 0.03, opacity: 1.00)
                        } else if distanceToSchnitzel! <= NumberEnum.regionRadius.rawValue/3 {
                                  let blue: Double = distanceToSchnitzel! / (NumberEnum.regionRadius.rawValue/3)
                                  let red: Double = 1.0 - blue
                                  return Color(red: red, green: 0.0, blue: blue, opacity: 1.00)
                        } else {
                                  let green: Double = distanceToSchnitzel! / (NumberEnum.regionRadius.rawValue*2)
                                  let blue: Double = 1.0 - green
                                  return Color(red: 0.0, green: green, blue: blue, opacity: 1.00)
                        }
                        
              default: return Color(red: 0.18, green: 0.52, blue: 0.03, opacity: 1.00) //darkgreen
              }
    }
    
}
