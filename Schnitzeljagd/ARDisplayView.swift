//
//  ARDisplayView.swift
//  schnitzeljagd_v2
//
//  Created by admin on 24.05.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit

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
}

// Add a Schnitzel by tapping
 extension ARView {
    @objc func addSchnitzelToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        let hitTestResults = self.hitTest(tapLocation, types: .existingPlane)

        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform
        let x = translation.columns.3.x
        let y = translation.columns.3.y
        let z = translation.columns.3.z

        let schnitzelAnchor = try! Experience.loadSchnitzel()
        schnitzelAnchor.position = SIMD3<Float>(x,y,z)
        self.scene.anchors.append(schnitzelAnchor)
    }

    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.addSchnitzelToSceneView(withGestureRecognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer)
        print("New Schnitzel")
    }
}
    


#if DEBUG
struct ARDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ARDisplayView()
    }
}
#endif
