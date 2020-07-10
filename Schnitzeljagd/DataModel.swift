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
import SwiftUI

final class DataModel: ObservableObject {
    
    static var shared = DataModel() // Singleton
    
    // Firebase
    @Published var ref: DatabaseReference! = Database.database().reference()
    
    // AR
    @Published var arView: ARView!
    var worldMap: ARWorldMap?
    @Published var showMissingWorldmapAlert: Bool = true
    @Published var hasPlacedSchnitzel: Bool = false
    var isTakingSnapshot: Bool = false
    var schnitzelARAnchor: ARAnchor?
    
    // UI
    var uiViews: UIViews?

    // Map + Location related
    let locationManager: CLLocationManager = CLLocationManager()
    let locationDelegate: LocationDelegate = LocationDelegate()
    @Published var location: CLLocation?
    let mapViewDelegate: MapViewDelegate? = MapViewDelegate()
    @Published var showStartSearchAlert: Bool = false
    @Published var showAnnotationInfoAlert: Bool = false
    var currentRegions: Set<CLRegion> = Set<CLRegion>()
    var loadedData: LoadedData = LoadedData()
    
    @Published var screenState: ScreenState {
        didSet {
            uiViews!.refreshAll()
            if (oldValue == .SEARCH_SCHNITZEL_MAP || oldValue == .SEARCH_SCHNITZEL_AR)
                && (screenState != .SEARCH_SCHNITZEL_MAP || screenState != .SEARCH_SCHNITZEL_AR) {
                self.loadedData.currentSchnitzelJagd!.saveTime()
            }
            if screenState != oldValue {
                initNewARView()
            }
        }
    }
    
    #if !targetEnvironment(simulator)
    
    // MARK: - Initialise DataModel
    init() {
        screenState = ScreenState.MENU_MAP
        initNewARView()
        initLocationServices()
    }
    
    func initNewARView() {
        let newArView = ARView(frame: .zero)
        newArView.addTapGestureToSceneView()
        newArView.session.delegate = newArView
        self.arView = newArView
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

    #endif
    
}

enum ScreenState {
    
    case MENU_MAP
    case SEARCH_SCHNITZEL_MAP
    case SEARCH_SCHNITZEL_AR
    case PLACE_SCHNITZEL_AR
    
}

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
