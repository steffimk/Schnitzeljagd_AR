//
//  ARUIView.swift
//  schnitzeljagd_v2
//
//  Created by admin on 24.05.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import SwiftUI

struct ARUIView: View {
    @EnvironmentObject var data: DataModel
    var body: some View {
        List {
            Toggle(isOn: $data.enableAR) {
                Text("AR")
            }
//            Stepper("X: \(Int(data.xTranslation))", value:$data.xTranslation, in: -100...100)
//            Stepper("y: \(Int(data.yTranslation))", value:$data.yTranslation, in: -100...100)
//            Stepper("XZ \(Int(data.zTranslation))", value:$data.zTranslation, in: -100...100)
        }
        .frame(width: CGFloat(200))
    }
}

struct ARUIView_Previews: PreviewProvider {
    static var previews: some View {
        ARUIView()
    }
}
