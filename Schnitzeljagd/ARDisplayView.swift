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

#if !targetEnvironment(simulator)


struct ARDisplayView: View {
    
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    
    func makeUIView(context: Context) -> ARView {
        return DataModel.shared.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

extension ARView: ARCoachingOverlayViewDelegate, ARSessionDelegate {
    
    
    func addCoaching() {
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        coachingOverlay.goal = .horizontalPlane
        self.addSubview(coachingOverlay)
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        //Ready to add entities next?
    }
    
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            print("New Anchor added: \(anchor)")
        }
    }
    
    // Add a Schnitzel by tapping
    @objc func addSchnitzelToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        for anchor in self.scene.anchors {
            if anchor.name == "SchnitzelAnchor" {
                self.scene.removeAnchor(anchor)
            }
        }
        let tapLocation = recognizer.location(in: self)
//        let hitTestResults = self.hitTest(tapLocation, types: .existingPlane)
        
        let result = DataModel.shared.arView.raycast(
          from: tapLocation,
          allowing: .existingPlaneGeometry, alignment: .horizontal
        ).first

//        guard let hitTestResult = hitTestResults.first else { return }
//        let translation = hitTestResult.worldTransform
//        let x = translation.columns.3.x
//        let y = translation.columns.3.y
//        let z = translation.columns.3.z

        let schnitzelExperience = try! Experience.loadSchnitzel()
        let schnitzel = schnitzelExperience.schnitzel as? HasCollision
        schnitzel!.generateCollisionShapes(recursive: true)
        DataModel.shared.arView.installGestures(.all, for: schnitzel!)
//        schnitzelExperience.position = SIMD3<Float>(x,y,z)
//        self.scene.anchors.append(schnitzelExperience)
        
//        let anchorEntity = AnchorEntity(world: SIMD3<Float>(x,y,z))
        guard result != nil else { return }
        let anchorEntity = AnchorEntity(raycastResult: result!)
        anchorEntity.name = "SchnitzelAnchor"
        anchorEntity.addChild(schnitzelExperience)
        self.scene.anchors.append(anchorEntity)
        
//        DataModel.shared.arView.session.getCurrentWorldMap { worldMap, error in
//            guard worldMap != nil else { return }
//            worldMap!.anchors.append(ARAnchor(name: "SchnitzelARAnchor", transform: result!.worldTransform))
//            print("worldmap: \(worldMap!.anchors.description)")
//        }
        
        DataModel.shared.hasPlacedSchnitzel = true
        
    }

    func addTapGestureToSceneView(screenState: ScreenState){
        print(screenState)
        if screenState == .PLACE_SCHNITZEL_AR {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.addSchnitzelToSceneView(withGestureRecognizer:)))
            self.addGestureRecognizer(tapGestureRecognizer)
        }
    }
}


#if DEBUG
struct ARDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ARDisplayView()
    }
}
#endif
#endif
