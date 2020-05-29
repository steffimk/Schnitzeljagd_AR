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
    VStack {
        Button(action: {
            self.data.enableAR.toggle()
        }) {
            Text("AR")
                .fontWeight(.bold)
                .font(.title)
                .padding()
                .background(Color.blue)
                .cornerRadius(40)
                .foregroundColor(.white)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.purple, lineWidth: 5)
                )
        }.padding()
//            Stepper("X: \(Int(data.xTranslation))", value:$data.xTranslation, in: -100...100)
//            Stepper("y: \(Int(data.yTranslation))", value:$data.yTranslation, in: -100...100)
//            Stepper("XZ \(Int(data.zTranslation))", value:$data.zTranslation, in: -100...100)
    }
}
}

struct ARUIView_Previews: PreviewProvider {
    static var previews: some View {
        ARUIView()
    }
}
