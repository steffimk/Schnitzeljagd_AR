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
    
    init() {
        self.snapshotThumbnail = DataModel.shared.loadedData.currentSchnitzelJagd?.snapshot
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ARViewContainer().edgesIgnoringSafeArea(.all)
            if DataModel.shared.screenState == .SEARCH_SCHNITZEL_AR && self.snapshotThumbnail != nil {
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
//        switch (frame.camera.trackingState) {
//        case .limited(_:)(.relocalizing) :
//            print("Camera trying to reconcile world map")
//        case .limited(_:)(.initializing) :
//            print("Camera initializing")
//        case .normal :
//            print("Camera in normal tracking state ")
//        default: if DataModel.shared.screenState == .SEARCH_SCHNITZEL_AR { print("Camera not relocalizing") }
//        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        print(messages.compactMap({ $0 }).joined(separator: "\n"))
        
    }
    
    func resetTracking() {
        print("Resetting tracking")
        let config = self.session.configuration ?? self.defaultConfiguration
        self.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func handleGestureInSearchMode(withGestureRecognizer recognizer: UIGestureRecognizer) {
        // TODO: geht noch nicht
        let touchInView = recognizer.location(in: self)
        guard self.entity (at: touchInView) != nil else {
                print("Touch not on entity")
                return
        }
        DataModel.shared.loadedData.currentSchnitzelJagd!.found() // TODO: richtig beenden
        if DataModel.shared.screenState == .SEARCH_SCHNITZEL_AR {
            let uiView = DataModel.shared.uiViews!.getSearchARUIView()
            uiView.showFoundAlert = true
            uiView.timer.upstream.connect().cancel()
            print("Clicked on schnitzel")
        }
    }
    
    // Add a Schnitzel by tapping
    @objc func addSchnitzelToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        if DataModel.shared.screenState == .SEARCH_SCHNITZEL_AR {
            handleGestureInSearchMode(withGestureRecognizer: recognizer)
            return
        }
        
        self.removeSchnitzelAndCornInScene()
        
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
        
        if DataModel.shared.isVeggie {
            let schnitzelAnchor = try! Experience.loadCorn()
            schnitzelAnchor.name = TextEnum.schnitzelAnchorEntity.rawValue
            let corn = schnitzelAnchor.corn as? HasCollision
            corn!.generateCollisionShapes(recursive: true)
            DataModel.shared.arView.installGestures(.all, for: corn!)
            schnitzelAnchor.position = SIMD3<Float>(x,y,z)
            self.scene.addAnchor(schnitzelAnchor)
        } else {
            let schnitzelAnchor = try! Experience.loadSchnitzel()
            schnitzelAnchor.name = TextEnum.schnitzelAnchorEntity.rawValue
            let schnitzel = schnitzelAnchor.schnitzel as? HasCollision
            schnitzel!.generateCollisionShapes(recursive: true)
            DataModel.shared.arView.installGestures(.all, for: schnitzel!)
            schnitzelAnchor.position = SIMD3<Float>(x,y,z)
            self.scene.addAnchor(schnitzelAnchor)
        }
        
        // Remove planes that are showed to help place the schnitzel
        DataModel.shared.arView.debugOptions = []
        
        DataModel.shared.schnitzelARAnchor = ARAnchor(name: TextEnum.schnitzelARAnchor.rawValue, transform: translation)
        self.session.add(anchor: DataModel.shared.schnitzelARAnchor!)
    
        DataModel.shared.hasPlacedSchnitzel = true
        
    }

    func addTapGestureToSceneView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.addSchnitzelToSceneView(withGestureRecognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func loadSchnitzel() {

        let worldMap = DataModel.shared.loadedData.currentSchnitzelJagd!.worldMap!

        let configuration = self.defaultConfiguration
        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors, .resetSceneReconstruction] )
        configuration.initialWorldMap = worldMap
        print("camera should be reconciling")

        print("WorldMap anchors: \(worldMap.anchors.description)")
        
        for anchor in self.scene.anchors {
            self.scene.removeAnchor(anchor)
        }
        
        for anchor in worldMap.anchors {
            let newAnchorEntity = AnchorEntity(anchor: anchor)
            if let anchorName = anchor.name {
                if anchorName == TextEnum.schnitzelARAnchor.rawValue {
                    if DataModel.shared.isVeggie {
                        let schnitzelAnchor = try! Experience.loadCorn()
                        schnitzelAnchor.name = TextEnum.schnitzelAnchorEntity.rawValue
                        schnitzelAnchor.transform.matrix = anchor.transform
                        let schnitzel = schnitzelAnchor.corn as? HasCollision
                        schnitzel!.generateCollisionShapes(recursive: true)
                        self.scene.addAnchor(schnitzelAnchor)
                        print(self.scene.findEntity(named: TextEnum.cornEntity.rawValue)?.debugDescription ?? "No Corn in Scene")
                    } else {
                        let schnitzelAnchor = try! Experience.loadSchnitzel()
                        schnitzelAnchor.name = TextEnum.schnitzelAnchorEntity.rawValue
                        schnitzelAnchor.transform.matrix = anchor.transform
                        let schnitzel = schnitzelAnchor.schnitzel as? HasCollision
                        schnitzel!.generateCollisionShapes(recursive: true)
                        self.scene.addAnchor(schnitzelAnchor)
                        print(self.scene.findEntity(named: TextEnum.schnitzelEntity.rawValue)?.debugDescription ?? "No Schnitzel in Scene")
                    }

                }
            }
            self.scene.addAnchor(newAnchorEntity)
        }

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
        let shiftedCoordinatesSmall = StaticFunctions.calculateRandomCenter(latitude: lat, longitude: lon, maxOffsetInMeters: Int(NumberEnum.regionRadiusSmall.rawValue/2))
        
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
            dataModel.ref.child("Schnitzel").child(schnitzelId).child("RegionCenterSmall").setValue(["latitude": shiftedCoordinatesSmall.latitude, "longitude": shiftedCoordinatesSmall.longitude])
            dataModel.ref.child("Schnitzel").child(schnitzelId).child("User").setValue(userID)
            dataModel.ref.child("Schnitzel").child(schnitzelId).child("Titel").setValue(title)
            dataModel.ref.child("Schnitzel").child(schnitzelId).child("Description").setValue(description)
            dataModel.ref.child("Schnitzel").child(schnitzelId).child("Location").setValue(["latitude": lat, "longitude": lon])
            dataModel.hasPlacedSchnitzel = false
        }
        
    }
    
    func loadHelperSchnitzel() {
        
        self.removeSchnitzelAndCornInScene()
        
        if DataModel.shared.isVeggie {
            
            let cornExperience = try! Experience.loadCorn()
            cornExperience.name = TextEnum.schnitzelAnchorEntity.rawValue
            cornExperience.position = SIMD3<Float>(0, 0, 0)
            self.scene.addAnchor(cornExperience)
            return
        }
        
        let schnitzelExperience = try! Experience.loadSchnitzel()
        schnitzelExperience.name = TextEnum.schnitzelAnchorEntity.rawValue
        schnitzelExperience.position = SIMD3<Float>(0, 0, 0)
        
        self.scene.addAnchor(schnitzelExperience)
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
    
    func removeSchnitzelAndCornInScene() {
        
        for anchor in self.scene.anchors {
            if anchor.name == TextEnum.schnitzelAnchorEntity.rawValue {
                self.scene.removeAnchor(anchor)
            }
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
