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

extension ARWorldMap {
    #if !targetEnvironment(simulator)
    var snapshotAnchor: SnapshotAnchor? {
        return anchors.compactMap { $0 as? SnapshotAnchor }.first
    }
    #endif
}

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

final class DataModel: ObservableObject {
    static var shared = DataModel() // Singleton
    
    //AR
    @Published var arView: ARView!

    @Published var screenState: ScreenState {
        didSet {
            if (oldValue == .SEARCH_SCHNITZEL_MAP || oldValue == .SEARCH_SCHNITZEL_AR)
                && (screenState != .SEARCH_SCHNITZEL_MAP || screenState == .SEARCH_SCHNITZEL_AR) {
                self.loadedData.currentSchnitzelJagd!.saveTime()
            }
        }
    }
    @Published var save: Bool = true
    @IBOutlet weak var snapshotThumbnail: UIImageView!
    
    // MARK: - Location
    let locationManager: CLLocationManager = CLLocationManager()
    let locationDelegate: LocationDelegate = LocationDelegate()
    @Published var location: CLLocation?
    let mapViewDelegate: MapViewDelegate? = MapViewDelegate()
    @Published var showStartSearchAlert: Bool = false
    var currentRegions: Set<CLRegion> = Set<CLRegion>()
    var loadedData: LoadedData = LoadedData()
    
    #if !targetEnvironment(simulator)
    // MARK: - Initialise the ARView
    init() {
        screenState = ScreenState.MENU_MAP
        // Initialise the ARView
        arView = ARView(frame: .zero)
        arView.addCoaching()
        arView.addTapGestureToSceneView()
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        
        initLocationServices()
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
    
    
    // MARK: - ARSessionObserver
    @IBOutlet weak var sessionInfoLabel: UILabel!
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.resetTracking(nil)
            }
            alertController.addAction(restartAction)
            //self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    // MARK: - Persistence: Saving and Loading
    lazy var mapSaveURL: URL = {
        do {
            return try FileManager.default
                .url(for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true)
                .appendingPathComponent("map.arexperience")
        } catch {
            fatalError("Can't get file save URL: \(error.localizedDescription)")
        }
    }()

    @Published var ref = Database.database().reference()
    @IBAction func saveSchnitzel(title: String, description: String) {

           let userID: String = (Auth.auth().currentUser?.uid)!
           let lat: Double = (locationManager.location?.coordinate.latitude)!
           let lon: Double = (locationManager.location?.coordinate.longitude)!
           let SchnitzelId: String = String(Date().toMillis())
           let shiftedCoordinates = AnnotationWithRegion.calculateRandomCenter(latitude: lat, longitude: lon, maxOffsetInMeters: Int(NumberEnum.regionRadius.rawValue))
        
           //self.ref.child("URL").child(userID).setValue(self.mapSaveURL.absoluteString)
           self.ref.child("Schnitzel").child(SchnitzelId).child("RegionCenter").setValue(["latitude": shiftedCoordinates.latitude, "longitude": shiftedCoordinates.longitude])
           self.ref.child("Schnitzel").child(SchnitzelId).child("User").setValue(userID)
           self.ref.child("Schnitzel").child(SchnitzelId).child("Titel").setValue(title)
           self.ref.child("Schnitzel").child(SchnitzelId).child("Description").setValue(description)
           self.ref.child("Schnitzel").child(SchnitzelId).child("Location").setValue(["latitude": lat, "longitude": lon])

        print("locations = \(lat) \(lon), shifted = \(shiftedCoordinates.latitude) \(shiftedCoordinates.longitude)")
           
           arView.session.getCurrentWorldMap { worldMap, error in
               guard let map = worldMap
                   else { return print("Can't get current world map")}
               
               // Add a snapshot image indicating where the map was captured.
               guard self.arView.session.currentFrame != nil else { return }
//               let image = self.arView.snapshot()
//               UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//               print("Saved snapshot")

               do {
                   let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                   self.ref.child("Data").child(userID).setValue(String(decoding: data, as: UTF8.self))
                   try data.write(to: self.mapSaveURL, options: [.atomic])
                   DispatchQueue.main.async {
                       return print("Saved Schnitzel")
                   }
               } catch {
                   fatalError("Can't save map: \(error.localizedDescription)")
               }
               worldMap!.anchors.removeAll()

           }
       }

    
    // Called opportunistically to verify that map data can be loaded from filesystem.
    var mapDataFromFile: Data? {
        var data: Data?
        let userID: String = (Auth.auth().currentUser?.uid)!
        self.ref.child("Data").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let d = value?[userID] as? String ?? ""
            data=d.data(using: .utf8)
        })
        
        //return data
        return try? Data(contentsOf: mapSaveURL)
    }
    
    /// - Tag: RunWithWorldMap
    @IBAction func loadSchnitzel() {
        
        /// - Tag: ReadWorldMap
        let worldMap: ARWorldMap = {
            guard let data = mapDataFromFile
                else { fatalError("Map data should already be verified to exist before Load button is enabled.") }
            do {
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
                    else { fatalError("No ARWorldMap in archive.") }
                return worldMap
            } catch {
                fatalError("Can't unarchive ARWorldMap from file data: \(error)")
            }
        }()
        
        let configuration = self.defaultConfiguration // this app's standard world tracking settings
        configuration.initialWorldMap = worldMap
        self.arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        isRelocalizingMap = true
        virtualObjectAnchor = nil
        
        print("Loaded Schnitzel")
    }
    
    // MARK: - AR session management
    
    var isRelocalizingMap = false

    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        return configuration
    }
    
    @IBAction func resetTracking(_ sender: UIButton?) {
        arView.session.run(defaultConfiguration, options: [.resetTracking, .removeExistingAnchors])
        isRelocalizingMap = false
        virtualObjectAnchor = nil
    }
    
    var virtualObjectAnchor: ARAnchor?
    let virtualObjectAnchorName = "virtualObject"

    let virtualObject = try! Experience.loadSchnitzel()
    
    #endif

}

enum ScreenState {
    
    case MENU_MAP
    case SEARCH_SCHNITZEL_MAP
    case SEARCH_SCHNITZEL_AR
    case PLACE_SCHNITZEL_AR
    
}
