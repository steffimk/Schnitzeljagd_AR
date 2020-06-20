//
//  ARUIView.swift
//  schnitzeljagd_v2
//
//  Created by Team Schnitzeljagd on 24.05.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import SwiftUI

#if !targetEnvironment(simulator)

struct PlaceSchnitzelUIView: View {
    @EnvironmentObject var data: DataModel
    
    var body: some View {
        HStack {
            if (self.data.save){
                Button(action: {
                    self.data.saveSchnitzel()
                    self.data.save = false
                }) {
                    Text(TextEnum.save.rawValue)
                        .fontWeight(.bold)
                        .modifier(TextModifier(color: .yellow))
                }
            } else {
                Button(action: {
                    self.data.loadSchnitzel()
                    self.data.save = true
                }){
                    Text(TextEnum.load.rawValue)
                        .fontWeight(.bold)
                        .modifier(TextModifier(color: .gray))
                }
            }
        }.padding(7).padding(.top, -10)
    }
}

struct MapUIView: View {
    @EnvironmentObject var data: DataModel
    
    var body: some View {
        HStack {
            Button(action: {
                self.data.screenState = .PLACE_SCHNITZEL_AR
            }) {
                Text(TextEnum.placeAR.rawValue)
                    .fontWeight(.bold)
                    .modifier(TextModifier())}
        }.padding(7).padding(.top, -10)
    }

}

struct SearchMapUIView: View {
    @EnvironmentObject var data: DataModel
    @State var timePassed = DataModel.shared.schnitzelJagd!.timePassed
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Text("Timer: \(timePassed)")
                 .onReceive(timer) { _ in
                     self.data.schnitzelJagd!.timePassed += 1
                     self.timePassed += 1
             }.font(.headline)
              .padding(8)
              .foregroundColor(.white)
            Spacer()
            Button(action: {
                self.data.screenState = .SEARCH_SCHNITZEL_AR
            }) {
                Text(TextEnum.searchAR.rawValue)
                    .fontWeight(.bold)
                    .modifier(TextModifier())}

        }.padding(7).padding(.top, -10)
    }

}

struct SearchARUIView: View {
    @EnvironmentObject var data: DataModel
    @State var timePassed = DataModel.shared.schnitzelJagd!.timePassed
       
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Text("Timer: \(timePassed)")
                 .onReceive(timer) { _ in
                    self.data.schnitzelJagd!.timePassed += 1
                    self.timePassed += 1
             }.font(.headline)
              .padding(8)
              .foregroundColor(.white)
            Spacer()
            Button(action: {
                self.data.screenState = .SEARCH_SCHNITZEL_MAP
            }) {
                Text(TextEnum.searchMap.rawValue)
                    .fontWeight(.bold)
                    .modifier(TextModifier(color: .green))
            }
        }.padding(7).padding(.top, -10)
    }

}

struct TextModifier: ViewModifier {
    
    var color: Color = .blue
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .padding(8)
            .background(color)
            .cornerRadius(40)
            .foregroundColor(.white)
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.purple, lineWidth: 4)
        )
    }
}

#endif
