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
        DataModel.shared.location = locations[locations.count-1] // save most recent location
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager){
        print("Location updates are paused")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager){
        print("Location updates are paused")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion){
        // TODO: Handle entered region
        print("User entered region")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion){
        // TODO: Handle exited region
        print("User exited region")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading){
        // TODO: Handle new Heading
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        switch(status){
        case .notDetermined: print("Location authorization not determined") // ask user to determine auth status
        case .restricted: print("Location authorization restricted") // app cannot function
        case .authorizedAlways: print("Location always authorized") // change nothing
        case .authorizedWhenInUse: print("Location autherized when in use") // change nothing
        default: print("Other location authorization")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed: " + error.localizedDescription)
    }

}
