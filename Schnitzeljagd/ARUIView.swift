//
//  ARUIView.swift
//  schnitzeljagd_v2
//
//  Created by Team Schnitzeljagd on 24.05.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import SwiftUI

#if !targetEnvironment(simulator)

struct ARUIView: View {
    @EnvironmentObject var data: DataModel
    var body: some View {
    VStack {
        Button(action: {
            self.data.enableAR.toggle()
        }) {
            if data.enableAR {
                Text(TextEnum.AR.rawValue)
                    .fontWeight(.bold)
                    .font(.title)
                    .padding(8)
                    .background(Color.green)
                    .cornerRadius(40)
                    .foregroundColor(.white)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.purple, lineWidth: 4)
                )
                Button(action: {
                    self.data.saveSchnitzel()
                }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .font(.title)
                            .padding(8)
                            .background(Color.yellow)
                            .cornerRadius(40)
                            .foregroundColor(.white)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color.purple, lineWidth: 4)
                        )
                }}
            else {
                Text(TextEnum.AR.rawValue)
                    .fontWeight(.bold)
                    .font(.title)
                    .padding(8)
                    .background(Color.blue)
                    .cornerRadius(40)
                    .foregroundColor(.white)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.purple, lineWidth: 4)
                )}
            }
    }.padding(7).padding(.top, -10)
    }
}

struct ARUIView_Previews: PreviewProvider {
    static var previews: some View {
        ARUIView()    }
}
#endif
