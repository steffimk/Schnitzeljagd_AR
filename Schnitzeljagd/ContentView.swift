//
//  ContentView.swift
//  schnitzeljagd_v2
//
//  Created by Team Schnitzeljagd on 24.05.20.
//  Copyright © 2020 PIOSE. All rights reserved.
//

import SwiftUI
import RealityKit
import MapKit

//struct ContentView : View {
//
//    @EnvironmentObject var data: DataModel
//    @EnvironmentObject var session: SessionStore
//
//    func getUser () {
//        session.listen()
//    }
    
//    var body: some View {
//        Group {
//            if (session.session != nil){
//                VStack {
//                  if data.enableAR {ARDisplayView()}
//                  else {MapView()}
//                  ARUIView()
//                }
//            } else {
//                SignInView()
//            }
//        }.onAppear(perform: getUser)
//
//    }
//}

struct ContentView : View {
    @EnvironmentObject var data: DataModel

    var body: some View {
          VStack {
              HStack {
                  Button(action: {}){
                  Image(systemName: "line.horizontal.3").foregroundColor(.white).font(Font.system(.title))
              }
              Spacer()
                  Text(TextEnum.appTitle.rawValue)
                  .font(.title)
                  .fontWeight(.bold)
                  .foregroundColor(.white)
              Spacer()
              Button(action: {}){
                  Image(systemName: "person.crop.circle").foregroundColor(.white).font(Font.system(.largeTitle))
              }
          }.padding()
            
          #if !targetEnvironment(simulator)
          if data.screenState == .PLACE_SCHNITZEL_AR {
              ARDisplayView().padding(.top, -15).padding(.bottom, -90)
          } else if data.screenState == .SEARCH_SCHNITZEL_MAP {
              SearchMapView().frame(maxHeight: .infinity).padding(.top, -15)
          } else {
              MapView().frame(maxHeight: .infinity).padding(.top, -15)
          }
          ARUIView()
          #endif
        }.background(getBackgroundColor())
          .alert(isPresented: $data.showStartSearchAlert) {
                    Alert(title: Text(TextEnum.alertTitle.rawValue), message: Text(TextEnum.alertMessage.rawValue),
                          primaryButton: .default(Text(TextEnum.alertAccept.rawValue), action: {
                              DataModel.shared.screenState = .SEARCH_SCHNITZEL_MAP
                              DataModel.shared.showStartSearchAlert = false
                          }),
                          secondaryButton: .cancel(Text(TextEnum.alertDecline.rawValue), action: {
                              DataModel.shared.showStartSearchAlert = false
                          }))
          }
    }
          
          func getBackgroundColor() -> Color {
                    switch data.screenState{
                    case .SEARCH_SCHNITZEL_MAP, .SEARCH_SCHNITZEL_AR: return Color.orange
                    default: return Color(red: 0.18, green: 0.52, blue: 0.03, opacity: 1.00) //darkgreen
                    }
          }
          
          
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
        .environmentObject(SessionStore())
    }
}
#endif
