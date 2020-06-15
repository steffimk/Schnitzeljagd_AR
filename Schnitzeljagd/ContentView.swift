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
            if data.enableAR {
                    ARDisplayView().padding(.top, -15).padding(.bottom, -90)
            }
            else { MapView().frame(maxHeight: .infinity).padding(.top, -15)}
            ARUIView()
            #endif
        }.background(Color(red: 0.18, green: 0.52, blue: 0.03, opacity: 1.00))
          .alert(isPresented: $data.showStartChaseAlert) {
                    Alert(title: Text(TextEnum.alertTitle.rawValue), message: Text(TextEnum.alertMessage.rawValue),
                          primaryButton: .default(Text(TextEnum.alertAccept.rawValue), action: {
                              DataModel.shared.enableAR = true; DataModel.shared.showStartChaseAlert = false
                          }),
                          secondaryButton: .cancel(Text(TextEnum.alertDecline.rawValue), action: {
                              DataModel.shared.showStartChaseAlert = false
                          }))
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
