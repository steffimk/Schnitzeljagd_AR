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
        
        //arView.session.run(config, options: [])
        
        // NOT WORKING YET - Add Raycast
//        let scene = try! Experience.loadSchnitzel()
//
//        func onTap(_ sender: UITapGestureRecognizer) {
//
//                scene.schnitzel!.name = "Schnitzel"
//
//                let tapLocation: CGPoint = sender.location(in: arView)
//                let estimatedPlane: ARRaycastQuery.Target = .estimatedPlane
//                let alignment: ARRaycastQuery.TargetAlignment = .horizontal
//
//                let result: [ARRaycastResult] = arView.raycast(from: tapLocation,
//                                                           allowing: estimatedPlane,
//                                                          alignment: alignment)
//
//                guard let rayCast: ARRaycastResult = result.first
//                else { return }
//
//                let anchor = AnchorEntity(world: rayCast.worldTransform)
//                anchor.addChild(scene)
//                arView.scene.anchors.append(anchor)
//
//                print(rayCast)
//            }
        
    }
    
    func initLocationServices(){
        self.locationManager.delegate = locationDelegate
        self.locationManager.requestWhenInUseAuthorization()
        // Stop monitoring all previously monitored regions
        for region in self.locationManager.monitoredRegions {
            self.locationManager.stopMonitoring(for: region)
        }
    }
}


