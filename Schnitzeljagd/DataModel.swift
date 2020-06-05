//
//  DataModel.swift
//  schnitzeljagd_v2
//
//  Created by Team Schnitzeljagd on 24.05.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import Foundation
import Combine
import RealityKit
import ARKit
import UIKit
import CoreLocation
import Firebase


final class DataModel: ObservableObject {
    static var shared = DataModel() // Singleton
    @Published var arView: ARView!
    @Published var enableAR: Bool = false
    
    // Location
    let locationManager: CLLocationManager = CLLocationManager()
    let locationDelegate: LocationDelegate = LocationDelegate()
    @Published var location: CLLocation?
    let mapViewDelegate: MapViewDelegate? = MapViewDelegate()
    
    init() {
        // Initialise the ARView
        #if !targetEnvironment(simulator)
        arView = ARView(frame: .zero)
        arView.addCoaching()
        arView.addTapGestureToSceneView()
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        
        initLocationServices()
        #endif
        
        arView.session.run(config, options: [])
        
    }
    
    func initLocationServices(){
        self.locationManager.delegate = locationDelegate
        self.locationManager.requestWhenInUseAuthorization()
        // Stop monitoring all previously monitored regions
        for region in self.locationManager.monitoredRegions {
            self.locationManager.stopMonitoring(for: region)
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    @Published var ref = Database.database().reference()
    func saveSchnitzel(){
            
            // let userID: String = (Auth.auth().currentUser?.uid)!
            let lat: Double = (locationManager.location?.coordinate.latitude)!
            let lon: Double = (locationManager.location?.coordinate.longitude)!

            // self.ref.child("Location").child(userID).setValue(["latitude": lat, "longitude": lon])
            self.ref.child("Location").setValue(["latitude": lat, "longitude": lon])
            print("locations = \(lat) \(lon)")
    }
    
    
}


