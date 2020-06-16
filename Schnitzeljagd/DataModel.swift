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


final class DataModel: ObservableObject {
    static var shared = DataModel() // Singleton
    
    //AR
    @Published var arView: ARView!
    @Published var screenState: ScreenState
    
    // Location related
    let locationManager: CLLocationManager = CLLocationManager()
    let locationDelegate: LocationDelegate = LocationDelegate()
    @Published var location: CLLocation?
    let mapViewDelegate: MapViewDelegate? = MapViewDelegate()
    @Published var showStartSearchAlert: Bool = false
    var currentRegions: Set<CLRegion> = Set<CLRegion>()
    
    // Schnitzeljagd
    var schnitzelJagd: SchnitzelJagd?
    
    init() {
        screenState = ScreenState.MENU_MAP
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
}

class SchnitzelJagd {
    
    var annotationWithRegion: AnnotationWithRegion
    
    init(annotation: AnnotationWithRegion){
        self.annotationWithRegion = annotation
    }
    
}

enum ScreenState {
    
    case MENU_MAP
    case SEARCH_SCHNITZEL_MAP
    case SEARCH_SCHNITZEL_AR
    case PLACE_SCHNITZEL_AR
    
}

