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
import MapKit
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
    
    // Hints
    @Published var showHintAlert: Bool = false
    @Published var availableHints: Int = 0
    @Published var smallRadius: Bool = false

    // Map + Location related
    let locationManager: CLLocationManager = CLLocationManager()
    let locationDelegate: LocationDelegate = LocationDelegate()
    @Published var location: CLLocation?
    let mapViewDelegate: MapViewDelegate? = MapViewDelegate()
    @Published var showStartSearchAlert: Bool = false
    @Published var showAnnotationInfoAlert: Bool = false
    var currentRegions: Set<CLRegion> = Set<CLRegion>()
    var loadedData: LoadedData = LoadedData()
    @Published var v: MKMapView!
    
    // State
    @Published var isVeggie: Bool = false
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
    
    @IBAction func showHint(){
        let userID: String = (Auth.auth().currentUser?.uid)!
        self.ref.child("Jagd").child(userID).child(self.loadedData.currentSchnitzelJagd!.schnitzelId).child("Hints").observeSingleEvent(of: .value, with: { (snapshot) in
            self.availableHints = snapshot.value as! Int
            self.availableHints -= 1
            if(self.availableHints < 0){
                self.availableHints = 0
            }
            self.ref.child("Jagd").child(userID).child(self.loadedData.currentSchnitzelJagd!.schnitzelId).child("Hints").setValue(self.availableHints)
            self.showHintAlert = true
        }) { (error) in
            print(error.localizedDescription)
        }
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
