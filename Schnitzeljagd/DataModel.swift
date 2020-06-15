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


final class DataModel: ObservableObject {
    static var shared = DataModel() // Singleton
    @Published var arView: ARView!
    @Published var enableAR: Bool = false
    @Published var save: Bool = true
    
    // MARK: - Location
    let locationManager: CLLocationManager = CLLocationManager()
    let locationDelegate: LocationDelegate = LocationDelegate()
    @Published var location: CLLocation?
    let mapViewDelegate: MapViewDelegate? = MapViewDelegate()
    #if !targetEnvironment(simulator)
    // MARK: - Initialise the ARView
    init() {
        
        arView = ARView(frame: .zero)
        arView.addCoaching()
        //arView.addTapGestureToSceneView()
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
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var saveExperienceButton: UIButton!
    @IBOutlet weak var loadExperienceButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var snapshotThumbnail: UIImageView!
    
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
    @IBAction func saveSchnitzel() {

        let userID: String = (Auth.auth().currentUser?.uid)!
        let lat: Double = (locationManager.location?.coordinate.latitude)!
        let lon: Double = (locationManager.location?.coordinate.longitude)!
        
        //self.ref.child("URL").child(userID).setValue(self.mapSaveURL.absoluteString)
        self.ref.child("Location").child(userID).setValue(["latitude": lat, "longitude": lon])
        //self.ref.child("Location").setValue(["latitude": lat, "longitude": lon])
        print("locations = \(lat) \(lon)")
        
        arView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { return print("Can't get current world map")}
            
            // Add a snapshot image indicating where the map was captured.
            guard let snapshotAnchor = SnapshotAnchor(capturing: self.arView)
                else { return print("Can't take snapshot") }
            map.anchors.append(snapshotAnchor)
            
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
            for anchor in self.arView.scene.anchors {
                self.arView.scene.removeAnchor(anchor)
            }
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
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
            // Update the UI to provide feedback on the state of the AR experience.
            let message: String
            
            snapshotThumbnail.isHidden = true
            switch (trackingState, frame.worldMappingStatus) {
            case (.normal, .mapped),
                 (.normal, .extending):
                if frame.anchors.contains(where: { $0.name == virtualObjectAnchorName }) {
                    // User has placed an object in scene and the session is mapped, prompt them to save the experience
                    message = "Tap 'Save Experience' to save the current map."
                } else {
                    message = "Tap on the screen to place an object."
                }
                
            case (.normal, _) where mapDataFromFile != nil && !isRelocalizingMap:
                message = "Move around to map the environment or tap 'Load Experience' to load a saved experience."
                
            case (.normal, _) where mapDataFromFile == nil:
                message = "Move around to map the environment."
                
            case (.limited(.relocalizing), _) where isRelocalizingMap:
                message = "Move your device to the location shown in the image."
                snapshotThumbnail.isHidden = false
                
            default:
                message = "trackingState.localizedFeedback"
            }
            
            sessionInfoLabel.text = message
            sessionInfoView.isHidden = message.isEmpty
        }
        
        // MARK: - Placing AR Content
        
        /// - Tag: PlaceObject
//        @IBAction func handleSceneTap(_ sender: UITapGestureRecognizer) {
//            // Disable placing objects when the session is still relocalizing
//            if isRelocalizingMap && virtualObjectAnchor == nil {
//                return
//            }
//            // Hit test to find a place for a virtual object.
//            guard let hitTestResult = sceneView
//                .hitTest(sender.location(in: sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
//                .first
//                else { return }
//
//            // Remove exisitng anchor and add new anchor
//            if let existingAnchor = virtualObjectAnchor {
//                sceneView.session.remove(anchor: existingAnchor)
//            }
//            virtualObjectAnchor = ARAnchor(name: virtualObjectAnchorName, transform: hitTestResult.worldTransform)
//            sceneView.session.add(anchor: virtualObjectAnchor!)
//        }
//
//        var virtualObjectAnchor: ARAnchor?
//        let virtualObjectAnchorName = "virtualObject"
//
//        let virtualObject = try! Experience.loadSchnitzel()
    
    @IBAction func handleSceneTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        // Disable placing objects when the session is still relocalizing
        if isRelocalizingMap && virtualObjectAnchor == nil {
            return
        }
        // Hit test to find a place for a virtual object.
        let tapLocation = recognizer.location(in: arView)
        let hitTestResults = arView.hitTest(tapLocation, types: .existingPlane)

        
        // Remove exisitng anchor and add new anchor
        if let existingAnchor = virtualObjectAnchor {
            arView.session.remove(anchor: existingAnchor)
        }
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform
        let x = translation.columns.3.x
        let y = translation.columns.3.y
        let z = translation.columns.3.z

        let schnitzelAnchor = try! Experience.loadSchnitzel()
        let schnitzel = schnitzelAnchor.schnitzel as? HasCollision
        schnitzel!.generateCollisionShapes(recursive: true)
        DataModel.shared.arView.installGestures(.all, for: schnitzel!)
        
        schnitzelAnchor.position = SIMD3<Float>(x,y,z)
        virtualObjectAnchor = ARAnchor(name: virtualObjectAnchorName, transform: translation)
        arView.scene.anchors.append(schnitzelAnchor)
        
        print("New Schnitzel")    }
    
    var virtualObjectAnchor: ARAnchor?
    let virtualObjectAnchorName = "virtualObject"
    
    func addTapGestureToSceneView() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(arView.addSchnitzelToSceneView(withGestureRecognizer:)))
        arView.addGestureRecognizer(tapGestureRecognizer)
    
    }
    
    #endif

}


