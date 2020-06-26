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

extension ARView: ARCoachingOverlayViewDelegate {
    
    
    func addCoaching() {
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        coachingOverlay.goal = .anyPlane
        self.addSubview(coachingOverlay)
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        //Ready to add entities next?
    }
    
    // Add a Schnitzel by tapping
    @objc func addSchnitzelToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        for anchor in self.scene.anchors {
            self.scene.removeAnchor(anchor)
        }
        let tapLocation = recognizer.location(in: self)
        let hitTestResults = self.hitTest(tapLocation, types: .existingPlane)

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
        self.scene.anchors.append(schnitzelAnchor)
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
