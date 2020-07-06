//
//  ARDisplayView.swift
//  schnitzeljagd_v2
//
//  Created by Team Schnitzeljagd on 24.05.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit
import UIKit
import Firebase

#if !targetEnvironment(simulator)


struct ARDisplayView: View {
    
    var snapshotThumbnail: UIImage?
    
    init(){
        self.snapshotThumbnail = DataModel.shared.loadedData.currentSchnitzelJagd?.snapshot
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ARViewContainer().edgesIgnoringSafeArea(.all)
            if ( DataModel.shared.screenState == .SEARCH_SCHNITZEL_AR && self.snapshotThumbnail != nil ) {
                Image(uiImage: self.snapshotThumbnail!)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .padding(20)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    
    func makeUIView(context: Context) -> ARView {
        let arView = DataModel.shared.arView
        if (DataModel.shared.screenState == .PLACE_SCHNITZEL_AR) {
            arView!.debugOptions = [.showAnchorGeometry]
        } else {
            arView!.debugOptions = []
        }
        arView?.session.run(arView!.defaultConfiguration, options: [.resetTracking, .removeExistingAnchors])
        return arView!
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

extension ARView: ARCoachingOverlayViewDelegate, ARSessionDelegate {
    
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        return configuration
    }
    
    func addCoaching() {
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        coachingOverlay.goal = .horizontalPlane
        self.addSubview(coachingOverlay)
    }
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            print("New Anchor added: \(anchor)")
        }
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        print("Session was interrupted")
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        print("Session interruption ended")
    }
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch (frame.camera.trackingState, frame.worldMappingStatus) {
        case (.limited(.relocalizing), _) where DataModel.shared.screenState == .SEARCH_SCHNITZEL_AR:
            print("trying to relocalize world map")
        default: if DataModel.shared.screenState == .SEARCH_SCHNITZEL_AR { print("not relocalizing") }
        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
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
                self.resetTracking()
            }
            alertController.addAction(restartAction)
            //self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func resetTracking() {
        self.session.run(defaultConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func handleGestureInSearchMode(withGestureRecognizer recognizer: UIGestureRecognizer){
        // TODO: geht noch nicht
        let touchInView = recognizer.location(in: self)
        guard self.entity (
            at: touchInView
            ) != nil else {
          return
        }
        DataModel.shared.loadedData.currentSchnitzelJagd!.found() // TODO: richtig beenden
        if DataModel.shared.screenState == .SEARCH_SCHNITZEL_AR {
            let uiView = DataModel.shared.uiViews!.getSearchARUIView()
            uiView.showFoundAlert = true
            uiView.timer.upstream.connect().cancel()
        }
    }
    
    // Add a Schnitzel by tapping
    @objc func addSchnitzelToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        if DataModel.shared.screenState == .SEARCH_SCHNITZEL_AR {
            handleGestureInSearchMode(withGestureRecognizer: recognizer)
            return
        }
        for anchor in self.scene.anchors {
            if anchor.name == "SchnitzelAnchor" {
                self.scene.removeAnchor(anchor)
            }
        }
        if DataModel.shared.schnitzelARAnchor != nil {
            self.session.remove(anchor: DataModel.shared.schnitzelARAnchor!)
        }
        
        let tapLocation = recognizer.location(in: self)
        let hitTestResults = self.hitTest(tapLocation, types: .existingPlane)

        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform
        let x = translation.columns.3.x
        let y = translation.columns.3.y
        let z = translation.columns.3.z

        let schnitzelExperience = try! Experience.loadSchnitzel()
        let schnitzel = schnitzelExperience.schnitzel as? HasCollision
        schnitzel!.generateCollisionShapes(recursive: true)
        DataModel.shared.arView.installGestures(.all, for: schnitzel!)
        schnitzelExperience.position = SIMD3<Float>(x,y,z)
        
        DataModel.shared.arView.debugOptions = []
        self.scene.anchors.append(schnitzelExperience)
        
        let anchorEntity = AnchorEntity(world: SIMD3<Float>(x,y,z))
        
        anchorEntity.name = "SchnitzelAnchor"
        anchorEntity.addChild(schnitzelExperience)
        self.scene.anchors.append(anchorEntity)
        
        DataModel.shared.schnitzelARAnchor = ARAnchor(name: "SchnitzelARAnchor", transform: translation)
        self.session.add(anchor: DataModel.shared.schnitzelARAnchor!)
        
        DataModel.shared.hasPlacedSchnitzel = true
        
    }

    func addTapGestureToSceneView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.addSchnitzelToSceneView(withGestureRecognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func loadSchnitzel() {

        let worldMap = DataModel.shared.loadedData.currentSchnitzelJagd!.worldMap!

        self.session.pause()
        let configuration = self.defaultConfiguration
        configuration.initialWorldMap = worldMap
        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors] )

        print("WorldMap anchors: \(worldMap.anchors.description)")
        for anchor in worldMap.anchors {
            let newAnchorEntity = AnchorEntity(anchor: anchor)
            if let anchorName = anchor.name {
                if anchorName == "SchnitzelARAnchor" {
                    let translation = anchor.transform.columns.3
                    let schnitzelExperience = try! Experience.loadSchnitzel()
                    schnitzelExperience.position = SIMD3<Float>(translation.x, translation.y, translation.z)
                    let schnitzel = schnitzelExperience.schnitzel as? HasCollision
                    schnitzel!.generateCollisionShapes(recursive: true)
                    self.scene.addAnchor(schnitzelExperience)
                }
            }
            self.scene.addAnchor(newAnchorEntity)
        }

        print("Schnitzel entity in scene: \(String(describing: self.scene.findEntity(named: "schnitzel")))")
        self.scene.findEntity(named: "schnitzel")?.isEnabled = true

        print("Loaded Schnitzel")
    }
    
    func saveSchnitzel(title: String, description: String) {
        
        let dataModel = DataModel.shared
        dataModel.isTakingSnapshot = true
        
        let userID: String = (Auth.auth().currentUser?.uid)!
        let lat: Double = (dataModel.locationManager.location?.coordinate.latitude)!
        let lon: Double = (dataModel.locationManager.location?.coordinate.longitude)!
        let schnitzelId: String = String(Date().toMillis())
        let shiftedCoordinates = StaticFunctions.calculateRandomCenter(latitude: lat, longitude: lon, maxOffsetInMeters: Int(NumberEnum.regionRadius.rawValue))
        
        self.session.getCurrentWorldMap { worldMap, error in
            guard worldMap != nil else {
                print("Beim Speichervorgang keine WorldMap vorhanden")
                return
            }
            print("make snapshot")
            let snapshotAnchor = SnapshotAnchor(capturing: self)
            snapshotAnchor.retrieveImage(capturing: self) { (imageData) in
                dataModel.isTakingSnapshot = false
                if imageData != nil {
                    worldMap!.anchors.append(snapshotAnchor)
                } else {
                    print("Snapshot kann nicht gespeichert werden")
                }
                print("worldmap anchors when saving: \(worldMap!.anchors.description)")
                dataModel.worldMap = worldMap!
                
                NSKeyedArchiver.setClassName("ARWorldMap", for: ARWorldMap.self)
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: dataModel.worldMap!, requiringSecureCoding: true)
                    dataModel.ref.child("Schnitzel").child(schnitzelId).child("Worldmap").setValue(data.base64EncodedString())
                        DispatchQueue.main.async {
                            return print("Saved Schnitzel: \(schnitzelId)")
                    }
                } catch {
                    print("Can't save map")
                }
            }
            dataModel.ref.child("Schnitzel").child(schnitzelId).child("RegionCenter").setValue(["latitude": shiftedCoordinates.latitude, "longitude": shiftedCoordinates.longitude])
            dataModel.ref.child("Schnitzel").child(schnitzelId).child("User").setValue(userID)
            dataModel.ref.child("Schnitzel").child(schnitzelId).child("Titel").setValue(title)
            dataModel.ref.child("Schnitzel").child(schnitzelId).child("Description").setValue(description)
            dataModel.ref.child("Schnitzel").child(schnitzelId).child("Location").setValue(["latitude": lat, "longitude": lon])
            dataModel.hasPlacedSchnitzel = false
        }
        
    }
    
    func checkWorldMap(){
        self.session.getCurrentWorldMap { worldMap, error in
            guard worldMap != nil else {
                DataModel.shared.showMissingWorldmapAlert = true
                print("Keine WorldMap vorhanden")
                return
            }
            DataModel.shared.showMissingWorldmapAlert = false
        }
    }
    
}

extension ARWorldMap {
    #if !targetEnvironment(simulator)
    var snapshotAnchor: SnapshotAnchor? {
        return anchors.compactMap { $0 as? SnapshotAnchor }.first
    }
    #endif
}


#if DEBUG
struct ARDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ARDisplayView()
    }
}
#endif
#endif
