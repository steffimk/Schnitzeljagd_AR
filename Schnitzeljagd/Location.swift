//
//  Location.swift
//  Schnitzeljagd
//
//  Created by Stefanie Kloss on 03.06.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import Foundation
import CoreLocation

class LocationDelegate : NSObject, CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DataModel.shared.location = locations.last! // saves most recent location
        if DataModel.shared.screenState == .MENU_MAP {
            for region in manager.monitoredRegions {
                let r = region as! CLCircularRegion
                let distance = locations.last!.distance(from: CLLocation(latitude: r.center.latitude, longitude: r.center.longitude))
                if distance <= r.radius {
                    DataModel.shared.currentRegions.insert(region)
                    print("User entered region \(region.identifier)")
                } else if distance > r.radius + 10 {        // TODO: Adjust? Currently 10 meters buffer to prevent flimmering
                    DataModel.shared.currentRegions.remove(region)
                }
                // manager.requestState(for: region)
            }
        }
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager){
        print("Location updates are paused")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager){
        print("Location updates are paused")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Location Manager started to monitor region \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion){
        print("User entered region \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion){
        print("User exited region \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        let stateValue: String
        switch(state){
        case .inside:
            stateValue = "Inside"
//            DataModel.shared.currentRegions.insert(region) // moved to didUpdateLocation
        case .outside:
            stateValue = "Outside"
//            DataModel.shared.currentRegions.remove(region) // moved to didUpdateLocation
        default: stateValue = "Unknown"
        }
        
        print("State of region \(region.identifier) determined: \(stateValue)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading){
        // TODO: Handle new Heading
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        switch(status){
        case .notDetermined:
            print("Location authorization not determined") // ask user to determine auth status
            manager.stopUpdatingLocation()
        case .restricted:
            print("Location authorization restricted")
            manager.stopUpdatingLocation()
        case .authorizedAlways:
            print("Location always authorized")
            manager.startUpdatingLocation()
        case .authorizedWhenInUse:
            print("Location authorized when in use")
            manager.startUpdatingLocation()
        default: print("Other location authorization")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
           // Location updates are not authorized.
           manager.stopUpdatingLocation()
        }
        print("Location Manager failed: " + error.localizedDescription)
    }

}
