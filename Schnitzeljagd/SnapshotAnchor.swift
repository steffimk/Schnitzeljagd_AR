//
//  SnapshotAnchor.swift
//  Schnitzeljagd
//
//  Created by admin on 08.06.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import Foundation
import ARKit
import RealityKit
#if !targetEnvironment(simulator)

/// - Tag: SnapshotAnchor
class SnapshotAnchor: ARAnchor {
    
    var imageData: Data?
    
    init(capturing view: ARView) {
        super.init(name: "snapshot", transform: view.cameraTransform.matrix)
        
    }
    
    func retrieveImage(capturing view: ARView, _ handler: @escaping (Data?) -> ()){
        view.snapshot(saveToHDR: false) { (image) in
            guard image != nil else {
                handler(nil)
                return
            }
            let data = image!.jpegData(compressionQuality: 0.5)
            self.imageData = data
            handler(data)
        }
    }
    
    required init(anchor: ARAnchor) {
        super.init(anchor: anchor)
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let snapshot = aDecoder.decodeObject(forKey: "snapshot") as? Data {
            self.imageData = snapshot
        } else {
            return nil
        }
        
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(imageData, forKey: "snapshot")
    }

}

extension ARWorldMap {

    var snapshotAnchor: SnapshotAnchor? {
        return anchors.compactMap { $0 as? SnapshotAnchor }.first
    }

}

#endif
