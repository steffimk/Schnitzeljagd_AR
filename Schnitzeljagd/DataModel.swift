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


final class DataModel: ObservableObject {
    static var shared = DataModel()
    @Published var arView: ARView!
    @Published var enableAR = false
    
    init() {
        // Initialise the ARView
        #if !targetEnvironment(simulator)
        arView = ARView(frame: .zero)
        arView.addCoaching()
        arView.addTapGestureToSceneView()
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        
        // Load the "Box" scene from the "Experience" Reality File
            let boxAnchor = try! Experience.loadSchnitzel()
            
            arView.scene.anchors.append(boxAnchor)

        #endif
        //arView.session.run(config, options: [])
        
        
    }
}


