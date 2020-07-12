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


#if DEBUG
struct ARDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ARDisplayView()
    }
}
#endif
#endif
