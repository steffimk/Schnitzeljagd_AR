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

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

final class DataModel: ObservableObject {
    static var shared = DataModel() // Singleton
    
    //AR
    @Published var arView: ARView!

    @Published var screenState: ScreenState
    @Published var save: Bool = true
    @Published var showAlert: Bool = true
    @Published var schnitzelId: String = ""
    @IBOutlet weak var snapshotThumbnail: UIImageView!
    @Published var ref: DatabaseReference! = Database.database().reference()
    
    // MARK: - Location
    let locationManager: CLLocationManager = CLLocationManager()
    let locationDelegate: LocationDelegate = LocationDelegate()
    @Published var location: CLLocation?
    let mapViewDelegate: MapViewDelegate? = MapViewDelegate()
    @Published var showStartSearchAlert: Bool = false
    var currentRegions: Set<CLRegion> = Set<CLRegion>()
    
    // Schnitzeljagd
    var schnitzelJagd: SchnitzelJagd?
    
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

    
    @IBAction func saveSchnitzel() {
        
        self.showAlert = true

        let userID: String = (Auth.auth().currentUser?.uid)!
        let lat: Double = (locationManager.location?.coordinate.latitude)!
        let lon: Double = (locationManager.location?.coordinate.longitude)!
        //self.ref.child("Schnitzel").childByAutoId()
        self.schnitzelId = String(Date().toMillis())
        
        self.ref.child("Schnitzel").child(self.schnitzelId).child("Location").setValue(["latitude": lat, "longitude": lon])
        self.ref.child("Schnitzel").child(self.schnitzelId).child("User").setValue(userID)
        self.ref.child("Schnitzel").child(self.schnitzelId).child("Titel").setValue("test")
        
        self.ref.child("Test").setValue("Test return")
        
        
        arView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { return print("Can't get current world map")}
            
//            // Add a snapshot image indicating where the map was captured.
//            guard let snapshotAnchor = SnapshotAnchor(capturing: self.arView)
//                else { return print("Can't take snapshot") }
//            map.anchors.append(snapshotAnchor)
            
            do {
                NSKeyedArchiver.setClassName("ARWorldMap", for: ARWorldMap.self)
                let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                self.ref.child("Schnitzel").child(self.schnitzelId).child("Worldmap").setValue(data.base64EncodedString())
                //try data.write(to: self.mapSaveURL, options: [.atomic])
                DispatchQueue.main.async {
                    return print("Saved Schnitzel")
                }
            } catch {
                fatalError("Can't save map: \(error.localizedDescription)")
            }
            for anchor in self.arView.scene.anchors {
                self.arView.scene.removeAnchor(anchor)
            }
            
        }
    }
    
    // Called opportunistically to verify that map data can be loaded from filesystem.
//    var mapDataFromFile: Data? {
//        var data: Data?
//        let userID: String = (Auth.auth().currentUser?.uid)!
//        self.ref.child("Data").observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let value = snapshot.value as? NSDictionary
//            let d = value?[userID] as? String ?? ""
//            data=d.data(using: .utf8)
//        })
//
//        //return data
//        return try? Data(contentsOf: mapSaveURL)
//    }
    
    /// - Tag: RunWithWorldMap
    @IBAction func loadSchnitzel() {

        self.ref.child("Schnitzel").child(self.schnitzelId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let schnitzelData = value?["Worldmap"] as? String ?? ""
            let data = Data(base64Encoded: schnitzelData)!

            /// - Tag: ReadWorldMap
            let worldMap: ARWorldMap = {

                do {
                    NSKeyedUnarchiver.setClass(ARWorldMap.self, forClassName: "ARWorldMap")
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

            self.isRelocalizingMap = true
            self.virtualObjectAnchor = nil

            print("Loaded Schnitzel")
          }) { (error) in
            print(error.localizedDescription)
        }
        
        self.ref.child("Test").setValue("Please read")
        
        
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

