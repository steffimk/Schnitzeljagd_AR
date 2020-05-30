//
//  DataModel.swift
//  schnitzeljagd_v2
//
//  Created by admin on 24.05.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import Foundation
import Combine
import RealityKit
import ARKit
import UIKit

final class DataModel: ObservableObject {
    static var shared = DataModel() // Singleton
    @Published var arView: ARView!
    @Published var enableAR = false
    @Published var xTranslation: Float = 0 {
        didSet {translateBox()}
    }
    @Published var yTranslation: Float = 0 {
        didSet {translateBox()}
    }
    @Published var zTranslation: Float = 0 {
        didSet {translateBox()}
    }
    
    init() {
        // Initialise the ARView
        arView = ARView(frame: .zero)
        
        arView.addCoaching()
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options: [])
                
        // Load the "Schnitzel" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadSchnitzel()
        let schnitzel = boxAnchor.schnitzel as? HasCollision
        arView.installGestures(.all, for: schnitzel!)
        schnitzel!.generateCollisionShapes(recursive: true)
        arView.scene.anchors.append(boxAnchor)
    }
    
    func translateBox() {
        // Try to find the steel box Entity
        if let schnitzel = (arView.scene.anchors[0] as? Experience.Schnitzel)?.schnitzel {
            // Convert centimeters to meters
            let xTranslationM = xTranslation / 100
            let yTranslationM = yTranslation / 100
            let zTranslationM = zTranslation / 100
            
            // Convert to a vector of 3 float values
            let translation = SIMD3<Float>(xTranslationM, yTranslationM, zTranslationM)
            
            // Translate the box by this amount
            schnitzel.transform.translation = translation
        }
    }
}

