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
        for region in manager.monitoredRegions {
            manager.requestState(for: region)
        }
        print("Location was updated")
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
        // TODO: Handle entered region
        print("User entered region \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion){
        // TODO: Handle exited region
        print("User exited region \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {

        let stateValue: String
        switch(state.rawValue){
        case 1:
            stateValue = "Inside"
            DataModel.shared.currentRegions.insert(region) // TODO: move to entered region
        case 2:
            stateValue = "Outside"
            DataModel.shared.currentRegions.remove(region) // TODO: move to exited region
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
